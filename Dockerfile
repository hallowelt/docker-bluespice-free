FROM ubuntu:18.04 as bsbuild
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i 's/archive.ubuntu.com/de.archive.ubuntu.com/g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get -y --no-install-recommends install \
 npm \
 wget \
 bzip2 \
 ca-certificates \
 build-essential \
 git \
 && cd /usr/local \
 && git clone --depth 1 --branch v0.10.0 https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid parsoid \
 && cd /usr/local/parsoid \
 && npm install \
 && find /usr/local/parsoid -iname '.git*' | xargs rm -rf \
 && cd /tmp \
 && wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin \
 && chmod +x /usr/local/bin/phantomjs \
 && rm -rf /tmp/phantomjs-2.1.1-linux-x86_64 \
 && rm -rf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && /usr/bin/wget --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HalloWelt-dfd/3.1.11" -O /opt/BlueSpice-free.zip https://bluespice.com/filebase/bluespice-free-3-1-10-2/

FROM ubuntu:18.04 as bsbase
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
 && apt-get update \	
 && apt-get -y dist-upgrade \
 && apt-get -y --no-install-recommends install \
	ca-certificates \
	python3 \
	cron \
	logrotate \
	gnupg2 \
	nginx \
	php-fpm \
	php-xml \
	php-mbstring \
	php-curl \
	unzip \
	php-zip \
	php-tidy \
	php-gd \
	php-cli \
	php-json \
	php-mysql \
	php-ldap \
	php-opcache \
	php-memcache \
	php-intl \
	wget \
	memcached \
	mysql-server \
	jetty9 \
	nodejs \
	imagemagick \
	poppler-utils \
	ghostscript \
 && mkdir -p /opt/docker/pkg \
 && cd /tmp \
 && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.8.deb \
 && dpkg -i /tmp/elasticsearch-6.8.8.deb \
 && /usr/share/elasticsearch/bin/elasticsearch-plugin install -b ingest-attachment \
 && mkdir -p /var/run/memcached \
 && mkdir -p /run/php \
 && apt-get -y purge wget \
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
COPY ./includes/init/init.sh /opt/docker/
COPY ./includes/misc/scripts/setwikiperm.sh /opt/docker/
RUN chmod a+x /opt/docker/*.sh \
 && mkdir -p /opt/docker/pkg \
 && mkdir -p /opt/docker/bluespice-data/extensions/BluespiceFoundation \
 && mkdir -p /opt/docker/bluespice-data/settings.d \
 && mkdir /data \
 && touch /opt/docker/.firstrun
COPY ./includes/bluespice-data /opt/docker/bluespice-data
COPY ./includes/misc/cron/bluespice /etc/cron.d/
COPY ./includes/misc/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
COPY ./includes/misc/nginx/bluespice.conf /etc/nginx/sites-available/
COPY ./includes/misc/nginx/bluespice-ssl.conf /etc/nginx/sites-available/
COPY ./includes/misc/nginx/fastcgi.conf /etc/nginx/
COPY ./includes/misc/nginx/nginx.conf /etc/nginx/
COPY --from=bsbuild /opt/BlueSpice-free.zip /opt/docker/pkg/
RUN rm /etc/nginx/sites-enabled/* \
 && ln -s /etc/nginx/sites-available/bluespice.conf /etc/nginx/sites-enabled/
COPY --from=bsbuild /usr/local/parsoid /usr/local/parsoid
COPY ./includes/misc/parsoid/parsoid.initd /etc/init.d/parsoid
COPY ./includes/misc/parsoid/config.yaml /usr/local/parsoid/
COPY ./includes/misc/parsoid/localsettings.js /usr/local/parsoid/
COPY ./includes/misc/pingback/pingback.js /opt/docker/
COPY --from=bsbuild /usr/local/bin/phantomjs /usr/local/bin
RUN chmod +x /etc/init.d/parsoid; \
	sed -i 's/^max_execution_time.*$/max_execution_time = 600/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^post_max_size.*$/post_max_size = 128M/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^upload_max_filesize.*$/upload_max_filesize = 128M/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;date.timezone.*$/date.timezone = Europe\/Berlin/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^memory_limit =.*$/memory_limit = 512M/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.enable=.*$/opcache.enable=1/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.memory_consumption.*$/opcache.memory_consumption=256/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.max_accelerated_files.*$/opcache.max_accelerated_files=1000000/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.validate_timestamps.*$/opcache.validate_timestamps=1/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.revalidate_freq.*$/opcache.revalidate_freq=2/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.optimization_level.*$/opcache.optimization_level=0x7FFF9FFF/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^zlib.output_compression.*$/zlib.output_compression=On/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;zlib.output_compression_level.*$/zlib.output_compression_level=9/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/-m 64/-m 128/g' /etc/memcached.conf; \
	sed -i 's/error_reporting =.*/error_reporting=E_ALL ^ E_NOTICE/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/error_reporting =.*/error_reporting=E_ALL ^ E_NOTICE/g' /etc/php/7.2/cli/php.ini; \
	echo "JAVA_OPTIONS=\"\-Xms512m -Xmx1024m -Djetty.home=127.0.0.1\"" >> /etc/default/jetty9; \
	chown -Rf www-data:www-data /run/php
EXPOSE 80 443
ENTRYPOINT /opt/docker/init.sh
