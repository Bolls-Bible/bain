### 1. Install `docker` and `docker-compose`
https://docs.docker.com/engine/install/debian/

### 2. Map domain name to the new host ip
1) Update GitHub Secrets for Actions. Set SSH_HOST to the new host ip
2) Also update domain name DNS to point ot the new host ip

### 3. Run pipeline
Create a brunch `feature/setup` and push it to GitHub to trigger automated pipeline. You may need to run it twice if database wasn't well setup at first run.

### 4. Populate database with default data
Go into database container
Download command (doesn't really work idk) `wget https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.dump`
`docker cp ./backup.dump db_dev:backup.dump`
`docker exec -i db_dev pg_restore -U django_dev -v -d cotton < backup.dump`

Copy command `scp backup.dump root@ip.ip.ip.ip:/root`
