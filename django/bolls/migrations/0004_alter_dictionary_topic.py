# Generated by Django 4.0 on 2021-12-15 19:18

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('bolls', '0003_dictionary_dictionary'),
    ]

    operations = [
        migrations.AlterField(
            model_name='dictionary',
            name='topic',
            field=models.CharField(max_length=64),
        ),
    ]
