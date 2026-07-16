from django.db import models
from django.db.models import F, Func
from django.contrib.auth.models import User
from django.contrib.postgres.indexes import GinIndex
from django.contrib.postgres.search import SearchVector
from pgvector.django import VectorField, HnswIndex


class Verses(models.Model):
    translation = models.CharField(max_length=120)
    book = models.PositiveSmallIntegerField()
    chapter = models.PositiveSmallIntegerField()
    verse = models.PositiveSmallIntegerField()
    text = models.TextField()
    embedding = VectorField(dimensions=1536, null=True, blank=True)

    def natural_key(self):
        return (self.translation, self.book, self.chapter, self.verse)

    class Meta:
        indexes = [
            models.Index(fields=["translation", "book", "chapter"]),
            models.Index(fields=["translation", "book", "chapter", "verse"]),
            HnswIndex(name="text_vector_index", fields=["embedding"], m=16, ef_construction=64, opclasses=["vector_cosine_ops"]),
        ]


class Commentary(models.Model):
    translation = models.CharField(max_length=120)
    book = models.PositiveSmallIntegerField()
    chapter = models.PositiveSmallIntegerField()
    verse = models.PositiveSmallIntegerField()
    text = models.TextField()

    class Meta:
        indexes = [
            models.Index(fields=["translation", "book", "chapter"]),
            models.Index(fields=["translation", "book", "chapter", "verse"]),
        ]


class Note(models.Model):
    text = models.TextField()


class Bookmarks(models.Model):
    verse = models.ForeignKey(Verses, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.BigIntegerField()
    color = models.CharField(max_length=32)
    collection = models.TextField(default=None)
    note = models.OneToOneField(Note, on_delete=models.CASCADE, null=True)


class History(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    history = models.TextField()
    purge_date = models.PositiveBigIntegerField(default=0)
    compare_translations = models.TextField(null=True, default=None)
    favorite_translations = models.TextField(null=True, default=None)


class Dictionary(models.Model):
    dictionary = models.CharField(max_length=8)
    topic = models.TextField()
    definition = models.TextField()
    lexeme = models.TextField()
    transliteration = models.TextField()
    pronunciation = models.TextField()
    short_definition = models.TextField(null=True)

    class Meta:
        indexes = [
            GinIndex(
                SearchVector(
                    Func(F("lexeme"), function="immutable_unaccent"),
                    config="simple",
                ),
                name="bolls_dict_lexeme_unaccent_idx",
            ),
            models.Index(fields=["topic"], name="bolls_dict_topic_idx"),
        ]
