import os
import re

from django.conf import settings
from django.contrib.staticfiles import finders


def find_static_match(pattern):
    regex = re.compile(pattern)
    newest_path = ""
    newest_mtime = None
    abs_path = ""

    for finder in finders.get_finders():
        for rel_path, storage in finder.list([]):
            if not regex.search(rel_path):
                continue

            mtime = None
            try:
                mtime = storage.get_modified_time(rel_path)
            except Exception:
                try:
                    mtime = os.path.getmtime(storage.path(rel_path))
                except Exception:
                    pass

            if mtime is None:
                if not newest_path:
                    newest_path = rel_path
                continue

            if newest_mtime is None or mtime > newest_mtime:
                newest_mtime = mtime
                newest_path = rel_path
                abs_path = storage.path(newest_path) if newest_path else ""

    if newest_path:
        return {
            "relative_path": newest_path,
            "absolute_path": abs_path
        }

    # Finders only search source directories; after collectstatic with the
    # source deleted, fall back to scanning STATIC_ROOT directly.
    static_root = getattr(settings, "STATIC_ROOT", None)
    if not static_root:
        return {"relative_path": "", "absolute_path": ""}

    for dirpath, _dirnames, filenames in os.walk(static_root):
        for filename in filenames:
            full_path = os.path.join(dirpath, filename)
            rel = os.path.relpath(full_path, static_root)
            if not regex.search(rel):
                continue

            try:
                mtime = os.path.getmtime(full_path)
            except OSError:
                mtime = None

            if mtime is None:
                if not newest_path:
                    newest_path = rel
                    abs_path = full_path
                continue

            if newest_mtime is None or mtime > newest_mtime:
                newest_mtime = mtime
                newest_path = rel
                abs_path = full_path

    return {
        "relative_path": newest_path,
        "absolute_path": abs_path
    }
