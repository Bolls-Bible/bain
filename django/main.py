from bain.asgi import application

# App Engine by default looks for a main.py file at the root of the app
# directory with a callable object called app.
# This file imports the ASGI-compatible object of your Django app,
# application from bain/asgi.py and renames it app so it is discoverable by
# App Engine without additional configuration.
# Alternatively, you can add a custom entrypoint field in your app.yaml:
# entrypoint: uvicorn bain.asgi:application --host 0.0.0.0 --port $PORT
app = application
