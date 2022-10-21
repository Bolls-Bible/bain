### 1. Install `docker` and `docker-compose`
https://docs.docker.com/engine/install/debian/

### 2. Map domain name anf GitHub Actions to the new host ip
1) Update GitHub Secrets for Actions. Set SSH_HOST to the new host ip and SSH_KEY to the ssh rsa key used on the server
2) Also update domain name DNS to point ot the new host ip

### 3. Run pipeline
Create a brunch `feature/setup` and push it to GitHub to trigger automated pipeline. You may need to run it twice if database wasn't well setup at first run.

### 4. Restore database with default data dump
Go into database container. Download backup:
`wget https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.dump`

If you copy backup from your laptop to server
`scp backup.dump root@ip.ip.ip.ip:/root`

Or if downloaded outside container copy to container:
`docker cp ./backup.dump db_dev:backup.dump`

Restore in one of these ways (depends on the backup you have done)
`docker exec -i db_dev pg_restore -U django_dev -v -d cotton < backup.dump`
`docker exec -i db_dev psql -U django_dev cotton < backup.dump`


### 5. After successful dump restoring -- don't forget to reset sequences. Log into dbs psql
`docker exec -it db_dev psql -U django_dev -d cotton`

Then run this code
```
CREATE OR REPLACE FUNCTION "reset_sequence" (tablename text, columnname text)
RETURNS "pg_catalog"."void" AS
$body$
DECLARE
BEGIN
    EXECUTE 'SELECT setval( pg_get_serial_sequence(''' || tablename || ''', ''' || columnname || '''),
    (SELECT COALESCE(MAX(id)+1,1) FROM ' || tablename || '), false)';
END;
$body$  LANGUAGE 'plpgsql';

SELECT table_name || '_' || column_name || '_seq', reset_sequence(table_name, column_name) FROM information_schema.columns where column_default like 'nextval%';
-- END
```
It may take a while before it completes



# What to test after set up

- login
- presense of bookmarks
- saving bookmarks
- apis are mostly covered with automated tests in the deploy pipeline -- watch it.