MerMEId
=======

[![Apache-2 License](https://img.shields.io/github/license/edirom/MerMEId)](https://github.com/Edirom/MerMEId/blob/develop/LICENSE)
[![GitHub release](https://img.shields.io/github/release/edirom/MerMEId.svg)](https://github.com/Edirom/MerMEId/releases)
[![Docker Testing](https://github.com/Edirom/MerMEId/actions/workflows/artifacts.yml/badge.svg)](https://github.com/Edirom/MerMEId/actions/workflows/artifacts.yml)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)
[![OpenSSF Best Practices](https://bestpractices.coreinfrastructure.org/projects/6926/badge)](https://bestpractices.coreinfrastructure.org/projects/6926)
[![fair-software.eu](https://img.shields.io/badge/fair--software.eu-%E2%97%8F%20%20%E2%97%8F%20%20%E2%97%8B%20%20%E2%97%8F%20%20%E2%97%8F-yellow)](https://fair-software.eu)

MerMEId is a system for the editing, handling, and (pre-)viewing of music
metadata, based on the the [Music Encoding Initiative](http://www.music-encoding.org/) (MEI)  XML schema. 
As of March 2019 MerMEId supports MEI 4.0.0.

MerMEId was originally developed at the [Danish Centre for Music Editing](http://www.kb.dk/en/nb/dcm/index.html) (DCM) both for
the production of thematic catalogues of works and for organizing source- and
work-related information during the preparation of scholarly editions of
music. It is now maintained as a community effort.

MerMEId is used for the creation and maintenance of 

* [Catalogue of Carl Nielsen's Works, CNW](http://www.kb.dk/dcm/cnw.html),
* [Johann Adolph Scheibe. A Catalogue of His Works](http://www.kb.dk/dcm/schw.html), and
* [J.P.E. Hartmann. A Thematic-Bibliographic Catalogue of His Works](http://www.kb.dk/dcm/hartw.html)

The services mentioned are delivered using [DCM Catalog UI](https://github.com/kb-dk/dcm_catalog_ui).

Try MerMEId at the [demo](https://mermeid.edirom.de/) website.


## How to use this Docker image

The most convenient way to set up MerMEId is by pulling the ready made Docker images from [DockerHub](https://hub.docker.com/r/edirom/mermeid).

### Start a MerMEId server instance

Starting a MerMEId instance is simple: 

```sh
$ docker run --name my-mermeid -p 8080:8080 -d edirom/mermeid:develop-java11-ShenGC
```

… where `my-mermeid` is the name you want to assign to your container and `8080` is the local port where the MerMEId server will listen.

### … via docker stack deploy or docker-compose

Example `stack.yml` for `MerMEId`:

```yaml
version: '3'

services:
  mermeid:
    image: edirom/mermeid:develop-java11-ShenGC
    ports: 
      - 8080:8080
    environment: 
      - MERMEID_exist_endpoint=http://localhost:8080
```

Run `docker stack deploy -c stack.yml mermeid` (or `docker-compose -f stack.yml up`), 
wait for it to initialize completely, and visit `http://localhost:8080`.

The default credentials to log in to the MerMEId are username "mermeid" and password "mermeid". 

### Environment Variables

When you start the `MerMEId` image, you can adjust the configuration of the `MerMEId` instance by passing one or more environment variables on the docker run command line.
In general, all settings from `properties.xml` can be overridden by providing the respective environment variable prefixed with 'MERMEID_'. Commonly used variables include:

#### `MERMEID_exist_endpoint`

this variable must reflect the deployment URL. 
E.g., if you deploy `MerMEId` to `https://my.mermeid.org` the `MERMEID_exist_endpoint` variable must be set to `https://my.mermeid.org` as well.

#### `MERMEID_admin_password`

provide an admin password. CAUTION: This will override any previously set password!

#### `MERMEID_admin_password_file`

provide an admin password via a secrets file. 
The environment variable `MERMEID_admin_password_file` must provide the path to that file within the container.
CAUTION: This will override any previously set password!

#### `MERMEID_mermeid_password`

provide a password for the mermeid user (defaults to "mermeid"). 
CAUTION: This will override any previously set password!

#### `MERMEID_mermeid_password_file`

provide a password for the mermeid user via a secrets file (defaults to "mermeid"). 
The environment variable `MERMEID_mermeid_password_file` must provide the path to that file within the container.
CAUTION: This will override any previously set password!

### Persistent Data Volume

For running the MerMEId service in production you probably want to persist the data volume. 
Otherwise restarting the container might result in data loss!

The database files are stored within `/exist/data` in the container so you simply mount a host directory there:
```
$ docker run --name my-mermeid -p 8080:8080 -d --mount type=bind,source="$(pwd)/exist-data",target=/exist/data edirom/mermeid:develop-java11-ShenGC
```

### Logs

Orbeon logs everything to stdout, so you can access them with `docker logs my-mermeid`. eXist-db writes most information into logfiles though, so in case you want to access them you should mount a host directory to `/exist/logs` like this:
```
$ docker run --name my-mermeid -p 8080:8080 -d --mount type=bind,source="$(pwd)/exist-logs",target=/exist/logs edirom/mermeid:develop-java11-ShenGC
```

### Updating

A word of warning: It is always recommended to back up your data before 
updating! eXist-db has [various ways to do a full or partial backup], at least 
you should save the files from the `$data-dir` (defaults to 
`/db/apps/mermeid-data`).

#### Without a persistent data directory

Without a persistent data directory you can simply pull the updated Docker image and run it as [described above](#start-a-mermeid-server-instance). 

#### With a persistent data directory

When you start an updated Docker image and mount your data directory to it as [described above](#persistent-data-volume), 
only the base image including eXist-db and Orbeon will be updated but not the MerMEId app. 
This needs to be done in a dedicated step via the eXist-db dashboard:
  1. Download the latest MerMEId xar package from the assets section at https://github.com/Edirom/MerMEId/releases, e.g. `mermeid-2.0.0-alpha.7.xar`
  2. Login as admin in the MerMEId or eXide app (needs to be done here due to a [bug in the eXist-db dashboard])
  3. Open `http://localhost:8080/apps/dashboard/admin#/packagemanager` and drop the xar package in the blue section to upload and install it


## Building the docker image

The Dockerfile in this repository has a ARG for specifying a base image containing an exist-db.
The reason for this is that we need different flavours of Java and exist-db to test with or for special deployment scenarios.
If you just do the standard

```
docker build --tag edirom/mermeid:latest .
```

The [official exist-db](https://hub.docker.com/r/existdb/existdb) 6.0.1 container will be used as the base image but
you can supply any image that is build using the same process instead. This is by running

```
mvn -Pdocker -DskipTests clean package
```

after checking out the particular version of exist 6.x to be built and changing the Dockerfile in
`exist-docker/src/main/resources-filtered/Dockerfile` as needed

```
docker build --build-arg EXISTDB_IMAGE=acdhch/existdb:6.0.1-java11-ShenGC --tag edirom/mermeid:java11-ShenGC .
```

## Legal notes

The MerMEId software and source code are licensed under the [Apache License 2.0](https://github.com/Edirom/MerMEId/blob/main/LICENSE). Please be aware of its implications.

When you run MerMEId in production and make it accessible from a public website, like with any other website please be advised to include an imprint page and a privacy policy that adheres to your applicable jurisdiction.

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct][CODE_OF_CONDUCT]. By participating in this project you agree to abide by its terms.

[CODE_OF_CONDUCT]: CODE_OF_CONDUCT.md
[bug in the eXist-db dashboard]: https://github.com/eXist-db/dashboard/issues/73
[various ways to do a full or partial backup]: https://exist-db.org/exist/apps/doc/backup
