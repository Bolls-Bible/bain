###########
# BUILDER #
###########

# pull official base image
FROM python:3.14-slim AS builder

# set work directory
WORKDIR /usr/src/bolls

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# install psycopg2 dependencies
RUN apt update -y \
    && apt install -y postgresql postgresql-contrib

# lint
RUN pip install --upgrade pip

# install dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/bolls/wheels -r requirements.txt

###################
# STATICS BUILDER #
###################

FROM node:24-alpine AS imba-builder

WORKDIR /usr/src/imba

COPY ./bolls/static/imba .

RUN npm install

RUN npm run build

#########
# FINAL #
#########

# pull official base image
FROM python:3.14-slim

# create directory for the bolls user
RUN mkdir -p /home/bolls

# create the bolls user
RUN addgroup bolls
RUN adduser --group $bolls bollsuser

# create the appropriate directories
ENV HOME=/home/bolls
ENV BOLLS_HOME=/home/bolls/web
RUN mkdir $BOLLS_HOME
WORKDIR $BOLLS_HOME

# install dependencies
RUN apt update -y && apt install -y netcat-traditional unzip curl
COPY --from=builder /usr/src/bolls/wheels /wheels
COPY --from=builder /usr/src/bolls/requirements.txt .
RUN pip install --no-cache /wheels/*

# copy project
COPY . $BOLLS_HOME

# copy imba statics
COPY --from=imba-builder /usr/src/imba/dist/ $BOLLS_HOME/bolls/static/imba/dist/

# chown all the files to the bolls user
RUN chown -R $bollsuser:$bolls $BOLLS_HOME
# RUN chown $bollsuser:$bolls $DAPHNE

# change to the bolls user
USER $bollsuser

# run entrypoint.sh
ENTRYPOINT ["/home/bolls/web/entrypoint.sh"]