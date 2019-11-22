![Blue Spice Logo](https://bluespice.com/wp-content/uploads/2017/07/BlueSpice-logo_final-mediawiki-v2017.png)

# How to use this image

## Introduction
This is an all in one image for Blue Spice. All required services are preconfigured.

## Basic usage
Example for quick start. Blue Spice will be accessible only in localhost.

    docker run -d -p 80:80 bluespice/bluespice-free
## Keep your data outside of the docker

    docker run -d -p 80:80 -v {/my/data/folder}:/data bluespice/bluespice-free
## Setting Blue Spice language and URL

	docker run -d -p 80:80 -v {/my/data/folder}:/data -e "bs_lang=en" -e "bs_url=http://www.domain.com" bluespice/bluespice-free
## Activating SSL
Using SSL inside the Blue Spice docker image, `data` directory should be outside of the docker. Create a folder named `cert` inside your data folder. Inside this folder, certificates must be named like:

 - `ssl.cert` (SSL certificate.  *mandatory*)
 - `ssl.key` (Private key of `ssl.cert`. *mandatory*)
 - `ssl.ca` (3rd party CA certs for `ssl.cert`.  *optional*)
 
 If everything is ready for first run, just run following command:
 

    docker run -d -p 80:80 -p 443:443 -v {/my/data/folder}:/data -e "bs_lang=en" -e "bs_url=https://www.domain.com" bluespice/bluespice-free

*Note: Port 443 includes the command and also `$bs_url` schema changed to `https`*

## Login to Blue Spice

    username: WikiSysop
    password: hallowelt

# Which services are runnning?

 - Apache
 - PHP-FPM
 - Jetty9
 - Elasticsearch
 - MySQL/MariaDB
 - Parsoid
 - crond
 - memcached

# Pingback

At the first boot of the container, we are sending a pingback to our servers for collecting of download statistics of docker image. This pingback is not collecting any data of your container or your current installation.
You can also easily disable this pingback with an environment variable. `DISABLE_PINGBACK=yes`

    docker run -d -p 80:80 -e DISABLE_PINGBACK=yes bluespice-free-image