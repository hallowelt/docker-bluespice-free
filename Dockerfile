FROM ubuntu:20.04 as main
RUN apt-get update \
 && apt-get -y --no-install-recommends install \
    gnupg2 \
	curl \
	ca-certificates \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
 && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" >> /etc/apt/sources.list \
 && echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu focal main" >> /etc/apt/sources.list \
 && apt-get update

FROM main as bsbuild
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV BLUESPICE_DOCKER_FREE_BUILD=BlueSpice-free.zip
ADD https://bluespice.com/filebase/bluespice-free/ /opt/${BLUESPICE_DOCKER_FREE_BUILD}
ADD https://buildservice.bluespice.com/webservices/REL1_31/BShtml2PDF.war /tmp/
ADD https://buildservice.bluespice.com/webservices/4.2.x/phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp/
ADD https://buildservice.bluespice.com/parsoid.zip /tmp/
RUN apt-get -y --no-install-recommends install \
 bzip2 unzip \
 && cd /tmp \
 && tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin \
 && chmod +x /usr/local/bin/phantomjs \
 && rm -rf /tmp/phantomjs-2.1.1-linux-x86_64 \
 && rm -rf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN cd /tmp && unzip -qq parsoid.zip
COPY ./includes/misc/parsoid/config.yaml /tmp/parsoid/
COPY ./includes/misc/parsoid/localsettings.js /tmp/parsoid/


FROM main as bsbase
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-6.8.23.deb /tmp/
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
 && apt-get -y --no-install-recommends install \
	python3 \
	cron \
	logrotate \
	nginx \
	unzip \
	memcached \
	mariadb-server \
	jetty9 \
	nodejs \
	imagemagick \
	poppler-utils \
	ghostscript \
	php8.2-fpm \
	php8.2-xml \
	php8.2-mbstring \
	php8.2-curl \
	php8.2-zip \
	php8.2-tidy \
	php8.2-gd \
	php8.2-cli \
	php8.2-mysql \
	php8.2-ldap \
	php8.2-opcache \
	php8.2-memcache \
	php8.2-intl \
 && mkdir -p /opt/docker/pkg \
 && cd /tmp \
 && dpkg -i /tmp/elasticsearch-oss-6.8.23.deb \
 && /usr/share/elasticsearch/bin/elasticsearch-plugin install -b ingest-attachment \
 && mkdir -p /var/run/memcached \
 && mkdir -p /run/php \
 && apt-get -y auto-remove \
 && apt-get -y clean \
 && apt-get -y autoclean \
 && rm -Rf /var/lib/apt/lists/* \
 && rm -Rf /tmp/* \
 && find /var/log -type f -delete \
 && ln -s /usr/bin/python3 /usr/bin/python

FROM bsbase
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV BLUESPICE_DOCKER_FREE_BUILD=BlueSpice-free.zip
COPY ./includes/install-scripts /opt/docker/install-scripts
COPY ./includes/misc/scripts/setwikiperm.sh /opt/docker/
RUN chmod a+x /opt/docker/*.sh /opt/docker/install-scripts/*.sh \
 && mkdir -p /opt/docker/pkg \
 && mkdir -p /opt/docker/bluespice-data/extensions/BluespiceFoundation \
 && mkdir -p /opt/docker/bluespice-data/settings.d \
 && mkdir /data \
 && mkdir -p /var/lib/jetty9/webapps \
 && touch /opt/docker/.firstrun
COPY ./includes/bluespice-data /opt/docker/bluespice-data
COPY ./includes/misc/cron/bluespice /etc/cron.d/
COPY ./includes/misc/mysql/mysqld.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./includes/misc/nginx/bluespice.conf /etc/nginx/sites-available/
COPY ./includes/misc/nginx/bluespice-ssl.conf /etc/nginx/sites-available/
COPY ./includes/misc/nginx/fastcgi.conf /etc/nginx/
COPY ./includes/misc/nginx/nginx.conf /etc/nginx/
COPY ./includes/misc/nginx/nginx.conf /etc/nginx/
COPY ./includes/misc/parsoid/parsoid.initd /etc/init.d/parsoid
COPY ./includes/misc/php/php.ini /etc/php/8.2/fpm/
COPY ./includes/misc/php/www.conf /etc/php/8.2/fpm/pool.d/
COPY ./includes/misc/php/opcache.blacklist /etc/php/opcache.blacklist
COPY --from=bsbuild /opt/${BLUESPICE_DOCKER_FREE_BUILD} /opt/docker/pkg/
RUN rm /etc/nginx/sites-enabled/* \
 && ln -s /etc/nginx/sites-available/bluespice.conf /etc/nginx/sites-enabled/
COPY ./includes/misc/pingback/pingback.js /opt/docker/
COPY --from=bsbuild /usr/local/bin/phantomjs /usr/local/bin
COPY --from=bsbuild /tmp/parsoid/ /usr/local/parsoid
COPY --from=bsbuild /tmp/BShtml2PDF.war /var/lib/jetty9/webapps
RUN chown jetty:adm /var/lib/jetty9/webapps/BShtml2PDF.war && echo "JAVA_OPTIONS=\"\-Xms512m -Xmx1024m -Djetty.home=127.0.0.1\"" >> /etc/default/jetty9; \
	chown -Rf www-data:www-data /run/php
RUN chmod +x /etc/init.d/parsoid

ENTRYPOINT /opt/docker/install-scripts/init.sh
