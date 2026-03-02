echo "Waiting for postgres..."
while ! nc -z database 5432; do
  sleep 0.1
done
echo "PostgreSQL started"

exec "$@"
