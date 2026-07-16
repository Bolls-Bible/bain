import time
from concurrent.futures import ThreadPoolExecutor, as_completed

from django.conf import settings
from django.core.management.base import BaseCommand

from mistralai.client import Mistral

from bolls.models import Verses


class Command(BaseCommand):
    help = "Backfill verse embeddings using Mistral embeddings API"

    def _embed_chunk(
        self,
        *,
        api_key,
        model_name,
        texts,
        expected_dims,
        max_retries,
        retry_sleep_seconds,
    ):
        """Embed a single request payload with retries.

        Returns a tuple (vectors, error_message).
        """
        client = Mistral(api_key=api_key)

        for attempt in range(max_retries + 1):
            try:
                response = client.embeddings.create(
                    model=model_name,
                    inputs=texts,
                    output_dimension=expected_dims,
                    output_dtype="float",
                )
                embeddings = getattr(response, "data", [])
                if len(embeddings) != len(texts):
                    return None, f"Embedding count mismatch: expected={len(texts)} got={len(embeddings)}"

                vectors = []
                for embedding_item in embeddings:
                    vector = getattr(embedding_item, "embedding", None)
                    if not vector or len(vector) != expected_dims:
                        got = len(vector) if vector else 0
                        return None, f"Invalid embedding length: got={got}, expected={expected_dims}"
                    vectors.append(vector)
                return vectors, None
            except Exception as exc:
                if attempt == max_retries:
                    return None, str(exc)
                time.sleep(retry_sleep_seconds)

        return None, "Unknown embedding error"

    def add_arguments(self, parser):
        parser.add_argument(
            "--translation",
            action="append",
            default=[],
            help="Translation code to process (can be passed multiple times)",
        )
        parser.add_argument(
            "--batch-size",
            type=int,
            default=getattr(settings, "VECTOR_EMBEDDING_BATCH_SIZE", 256),
            help="Rows to process per API batch",
        )
        parser.add_argument(
            "--force",
            action="store_true",
            help="Re-embed rows even when embedding already exists",
        )
        parser.add_argument(
            "--max-retries",
            type=int,
            default=3,
            help="Retries per embedding batch on transient errors",
        )
        parser.add_argument(
            "--retry-sleep-seconds",
            type=float,
            default=2.0,
            help="Delay between retries",
        )
        parser.add_argument(
            "--requests-per-second",
            type=float,
            default=float(getattr(settings, "MISTRAL_EMBEDDING_REQUESTS_PER_SECOND", 24)),
            help="Max embedding requests per second",
        )
        parser.add_argument(
            "--parallel-requests",
            type=int,
            default=int(getattr(settings, "MISTRAL_EMBEDDING_PARALLEL_REQUESTS", 24)),
            help="Max in-flight embedding requests",
        )

    def handle(self, *args, **options):
        api_key = getattr(settings, "MISTRAL_API_KEY", "")
        if not api_key:
            self.stderr.write("MISTRAL_API_KEY is not configured")
            return

        model_name = getattr(settings, "MISTRAL_EMBEDDING_MODEL", "codestral-embed")
        expected_dims = int(getattr(settings, "VECTOR_EMBEDDING_DIMENSIONS", 1536))

        selected_translations = options["translation"]
        if not selected_translations:
            self.stderr.write("No translations provided. Use --translation")
            return

        batch_size = max(1, int(options["batch_size"]))
        force = bool(options["force"])
        max_retries = max(0, int(options["max_retries"]))
        retry_sleep_seconds = float(options["retry_sleep_seconds"])
        requests_per_second = max(0.1, float(options["requests_per_second"]))
        parallel_requests = max(1, int(options["parallel_requests"]))
        super_batch_size = batch_size * parallel_requests

        queryset = Verses.objects.filter(translation__in=selected_translations).order_by("pk")
        if not force:
            queryset = queryset.filter(embedding__isnull=True)

        total = queryset.count()
        if total == 0:
            self.stdout.write("No verses to process")
            return

        self.stdout.write(
            f"Embedding {total} verses with request_batch_size={batch_size}, "
            f"parallel_requests={parallel_requests}, requests_per_second={requests_per_second}"
        )

        processed = 0
        failed = 0
        last_pk = 0
        next_dispatch_at = time.monotonic()
        overall_start = time.monotonic()
        super_batch_index = 0

        while True:
            super_batch = list(queryset.filter(pk__gt=last_pk)[:super_batch_size])
            if not super_batch:
                break

            super_batch_index += 1
            super_batch_start = time.monotonic()
            last_pk = super_batch[-1].pk
            chunked_batches = [
                super_batch[start:start + batch_size]
                for start in range(0, len(super_batch), batch_size)
            ]
            verses_to_update = []

            with ThreadPoolExecutor(max_workers=parallel_requests) as executor:
                futures = {}
                for chunk in chunked_batches:
                    now = time.monotonic()
                    sleep_for = next_dispatch_at - now
                    if sleep_for > 0:
                        time.sleep(sleep_for)
                    now = time.monotonic()
                    next_dispatch_at = max(next_dispatch_at + (1.0 / requests_per_second), now)

                    texts = [item.text for item in chunk]
                    if not texts:
                        continue

                    future = executor.submit(
                        self._embed_chunk,
                        api_key=api_key,
                        model_name=model_name,
                        texts=texts,
                        expected_dims=expected_dims,
                        max_retries=max_retries,
                        retry_sleep_seconds=retry_sleep_seconds,
                    )
                    futures[future] = chunk

                for future in as_completed(futures):
                    chunk = futures[future]
                    vectors, error = future.result()
                    if error:
                        failed += len(chunk)
                        self.stderr.write(
                            f"Batch failed near pk={chunk[-1].pk} (size={len(chunk)}): {error}"
                        )
                        continue

                    for verse, vector in zip(chunk, vectors):
                        verse.embedding = vector
                        verses_to_update.append(verse)

            super_batch_elapsed = time.monotonic() - super_batch_start
            total_elapsed = time.monotonic() - overall_start
            if not verses_to_update:
                self.stdout.write(
                    f"Processed {processed}/{total} (failed={failed}) "
                    f"batch={super_batch_index} batch_elapsed={super_batch_elapsed:.2f}s "
                    f"total_elapsed={total_elapsed:.2f}s"
                )
                continue

            try:
                Verses.objects.bulk_update(verses_to_update, ["embedding"], batch_size=super_batch_size)
            except Exception as exc:
                failed += len(verses_to_update)
                self.stderr.write(f"bulk_update failed near pk={last_pk}: {exc}")
                continue

            processed += len(verses_to_update)
            processing_rate = (processed / total_elapsed) if total_elapsed > 0 else 0.0
            self.stdout.write(
                f"Processed {processed}/{total} (failed={failed}) "
                f"batch={super_batch_index} batch_elapsed={super_batch_elapsed:.2f}s "
                f"total_elapsed={total_elapsed:.2f}s rate={processing_rate:.2f}/s"
            )

        total_elapsed = time.monotonic() - overall_start
        overall_rate = (processed / total_elapsed) if total_elapsed > 0 else 0.0
        self.stdout.write(
            f"Done. processed={processed} failed={failed} "
            f"total_elapsed={total_elapsed:.2f}s rate={overall_rate:.2f}/s"
        )


# Usage example:
# podman exec web python manage.py embed_verses --translation YLT
# podman exec web python manage.py embed_verses --translation UKRK
# python manage.py embed_verses --translation YLT --translation WEB --batch-size 128
