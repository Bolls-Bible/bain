# bain

## Setting up the repo

* clone the repo using git

``` bash
git clone https://github.com/Bohooslav/bain.git
```

* enter the directory

``` bash
cd bain/
```

* set up local enviroment

``` bash
pipenv
pipenv shell
```

* install reqirements using pip

``` bash
pipenv install -r requirements.txt
```

* run server (I am using 0 host for better debugging. You are free to use whatever you want)

``` bash
python manage.py runserver 0:8000
```

* and go to <http://0.0.0.0:8000/>
* check if everything is correct and you do not see any error. You will not see any verse, because to do that you should have installed PostreSQL, create bd 'bain', run migrations and fill a table 'bolls_verses' with translations. Ask me to get the translations  <https:t.me/Boguslavv>. Using pgAdmin or cmd, create a database `bain` , than run migrations:

``` bash
python manage.py makemigrations
python manage.py migrate
```

 and then insert the translation there.

* the next step is to go to `./bolls/static/bolls/` to install Imba dependencies

``` bash
cd bolls/static/bolls/
npm install
```

* than watch the changes in files to compile them

``` bash
npm run watch
```

After that you should be able to debug it.

### Checklist before any deploy

* sw
* npm run build
* collectstatic
* deploy

And do not forget to clean expired sessions sometimes

``` bash
python manage.py clearsessions
```
