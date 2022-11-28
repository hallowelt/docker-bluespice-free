<p align="center">
  <a href="https://bluespice.com/">
    <img src="https://upload.wikimedia.org/wikipedia/commons/a/a3/BlueSpice_Logo_v2020.png" alt="Logo" width=72 height=72>
  </a>

  <h3 align="center">BlueSpice</h3>
  <h6 align="center">Dockerized BlueSpice Free Edition v4</h6>

  <p align="center">
    BlueSpice free is an entry-level, no-cost version of BlueSpice pro. It sits on top of an existing MediaWiki without interfering with its architecture, adds lots of user-friendly features and supplements it with a multitude of helpful functions for teams and small businesses.
    <br>
    <a href="https://github.com/hallowelt/docker-bluespice-free/issues/new?template=bug.md">Report bug</a>
    ·
    <a href="https://github.com/hallowelt/docker-bluespice-free/issues/new?template=feature.md&labels=feature">Request feature</a>
    ·
    <a href="https://bluespice.com/products/bluespice-free/">Learn more</a>
  </p>
</p>

---

## Table of contents
- [Table of contents](#table-of-contents)
- [Version Info](#version-info)
- [Quick start](#quick-start)
- [Requirements](#requirements)
- [Configuration](#configuration)
- [Activating SSL](#activating-ssl)
- [Which services are runnning?](#which-services-are-runnning)
- [Bluespice CLI](#bluespice-cli)
- [Changelogs](#changelogs)

---

## Version Info
This <a href="https://github.com/hallowelt/docker-bluespice-free">docker-bluespice-free</a> is currently based on [BlueSpice 4](https://en.wikipedia.org/wiki/BlueSpice_MediaWiki#Versions)

---

## Quick start
1. Using docker cli:
    - To continue with the default config, create new .env:
      ```bash
      cp ./example.env ./.env
      ```
    - Set env vars:
      ```bash
      export $(grep -v '^#' ./.env | xargs)
      ```
    - Build docker image:
      ```bash
      docker build -t $IMAGE_NAME:$IMAGE_TAG .
      ```
      Note: If the data folder is inside the project dir, then also add this path in the .dockerignore
    - Create and run docker container:
      ```bash
      docker run \
      --env-file ./.env \
      -p $HTTP_PORT:80 \
      -p $HTTPS_PORT:443 \
      -v $WIKI_INSTALL_DIR:/data \
      -d $IMAGE_NAME:$IMAGE_TAG
      ```
2. Using bluespice cli:
   Quickly setup bluespice mediawiki on your system using followng steps:
   - Go inside the docker-bluespice-free directory after cloning it:
     - `cd docker-bluespice-free`
   - [Activate SSL](#activating-ssl) (optional)
   - Setup virtual environment and install dependencies:
     - `make run`
   - Setup [Configuration](#configuration) in `.env` file (optional)
   - Build and start docker container:
     - `./bluespice -bs`
   - After this the bluespice docker should start spinning up and install all the required dependencies. This could take some time (about 10 minutes). After that open your browser and go to `BS_URL`.
   - Enter the username as `BS_USER` and password as `BS_PASSWORD` to login.

---

## Requirements
- python >= 3.10
- pip >= 22.0
- docker >= 20.10

## Configuration
| name                            | default value    | description                                                    |
|---------------------------------|------------------|----------------------------------------------------------------|
| `BS_LANG`                       | en               | bluespice language                                             |
| `BS_URL`                        | http://localhost | url on which bluespice will be served                          |
| `BS_USER`                       | WikiSysop        | admin username                                                 |
| `BS_NAME`                       | Bluespice        | default wiki name                                              |
| `BS_PASSWORD`                   | PleaseChangeMe   | admin password                                                 |
| `BS_DB_PASSWORD`                | ThisIsDBPassword | default database password                                      |
| `HTTP_PORT`                     | 80               | server http port                                               |
| `HTTPS_PORT`                    | 443              | server https port                                              |
| `IMAGE_NAME`                    | bslocal/bsfree   | docker image name to be created                                |
| `IMAGE_TAG`                     | 4.2.3            | docker image tag                                               |
| `DISABLE_PINGBACK`              | no               | sends pingback to the bluespice servers                        |
| `WIKI_INSTALL_DIR`<sup>1</sup>  | ~/wiki           | dir where bluespice files will be stored                       |
| `WIKI_BACKUP_LIMIT`<sup>2</sup> | 5                | max limit of backups, after this the  oldest backup is deleted |

*1: During first boot, a pingback is sent to our servers for collecting download statistics of the docker image. This pingback is not collecting any data of your container or your current installation. You can also easily disable this pingback by setting it `yes`.*

*2: If `WIKI_INSTALL_DIR` path is changed and if this directory is inside the current projcet folder (docker-bluespice-free/) then also add the path in [.dockerignore](.dockerignore) and [.gitignore](.gitignore).*

---

## Activating SSL
Create a folder named `cert` inside your data folder. Inside this folder, certificates must be named like:

 - `ssl.cert` (SSL certificate.  *mandatory*)
 - `ssl.key` (Private key of `ssl.cert`. *mandatory*)
 - `ssl.ca` (3rd party CA certs for `ssl.cert`.  *optional*)

After adding the certificates, also update the `BS_URL` config to `https`. Restart the bluespice container using `./bluespice --restart` or continue with [Quick start](#quick-start).

---

## Which services are runnning?
 - Nginx
 - PHP-FPM
 - Jetty9
 - Elasticsearch
 - MySQL/MariaDB
 - Parsoid
 - crond
 - memcached

---

## Bluespice CLI

    usage: ./bluespice [-h] [-r] [-R] [-z] [-s] [-d] [-b] [-l]

    options:
    
    -h, --help            show this help message and exit
    -r, --restart         restarts the wiki container
    -R, --hard_restart    removes the container, deletes the local image, rebuilds image and then start the container again.
    -z, --stop            stops the running wiki container
    -s, --start           starts the bluespice wiki container
    -d, --clean_dangling  cleans the docker of all the dangling images
    -b, --build           builds the bluespice wiki container
    -l, --logs            stream logs from current wiki installation

---

## Changelogs
- Fixed data, config and local settings not getting copied while restoring wiki
- Added makefile installer
- Added `bluespice` cli
- Updated config
- Added wiki backup threshold limit

---

