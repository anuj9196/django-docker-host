FROM python:3.9.1-slim

ARG APP_USER=anychat
RUN groupadd -r ${APP_USER} && useradd --no-log-init -r -m -g ${APP_USER} ${APP_USER}

# default-libmysqlclient-dev -- Required for mysql database support
RUN set -ex \
    # Runtime dependencies
    && RUN_DEPS=" \
    default-libmysqlclient-dev \
    " \
    && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS \
    # Remove package list
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /static_my_project

WORKDIR /app/

ADD requirements.txt /requirements.txt
COPY ./src /app/
COPY scripts/ /scripts/


# build-essential -- Required to build mysqlclient dependency. https://packages.debian.org/sid/build-essential
# libpcre3-dev -- This is a library of functions to support regular expressions whose syntax and semantics are as close as possible to those of the Perl 5 language.
# libpq-dev -- Header files and static library for compiling C programs to link with the libpq library in order to communicate with a PostgreSQL database backend.
RUN set -ex \
    # Define build dependencies, they will be removed after build completes and libraries has been installed
    && BUILD_DEPS=" \
    build-essential \
#    libpcre3-dev \
#    libpq-dev \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && pip install -r /requirements.txt \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/scripts/docker/entrypoint.sh"]
