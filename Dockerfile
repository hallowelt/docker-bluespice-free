FROM ubuntu:bionic
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i 's/archive.ubuntu.com/de.archive.ubuntu.com/g' /etc/apt/sources.list
COPY ./includes/init/init.sh /opt/docker/
COPY ./includes/misc/scripts/setwikiperm.sh /opt/docker/
COPY ./includes/bluespice-data /opt/docker/bluespice-data
COPY ./includes/misc/cron/bluespice /etc/cron.d/
RUN chmod a+x /opt/docker/*.sh; \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone; \
	mkdir -p /opt/docker/pkg; \
	mkdir -p /opt/docker/bluespice-data/extensions/BluespiceFoundation; \
	mkdir -p /opt/docker/bluespice-data/settings.d; \
	mkdir /data ;\
	touch /opt/docker/.firstrun
RUN apt-get update; \
	apt-get -y dist-upgrade; \
	apt-get -y --no-install-recommends install \
	apt-transport-https \
	ssh-client \
	cron \
	logrotate \
	gnupg2 \
	imagemagick \
	bzip2 \
	apache2 \
	php-fpm \
	php-xml \
	php-mbstring \
	php-curl \
	unzip \
	php-zip \
	php-gd \
	php-tidy \
	php-cli \
	php-json \
	php-mysql \
	php-ldap \
	php-opcache \
	php-memcache \
	php-memcached \
	php-intl \
	php-pear \
	inkscape \
	curl \
	wget \
	python3 \
	poppler-utils \
	dvipng \
	memcached \
	git \
	mysql-server \
	jetty9 \
	npm\
	nodejs \
	ghostscript\
	build-essential
RUN  /usr/bin/wget --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HalloWelt-dfd/3.1.3" -O /opt/docker/pkg/BlueSpice-free.zip https://bluespice.com/?ddownload=2769 --progress=bar --show-progress
COPY ./includes/misc/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
COPY ./includes/misc/apache/bluespice.conf /etc/apache2/sites-available/
COPY ./includes/misc/apache/bluespice-ssl.conf /etc/apache2/sites-available/
RUN a2dissite 000-default; \
	a2ensite bluespice; \
	a2enmod proxy_fcgi setenvif rewrite ssl; \
	a2enconf php7.2-fpm
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -; \
	echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list; \
	apt-get update; \
	apt-get -y install elasticsearch; \
	/usr/share/elasticsearch/bin/elasticsearch-plugin install -b ingest-attachment
RUN cd /usr/local; \
	git clone --depth 1 --branch v0.10.0 https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid parsoid; \
	cd /usr/local/parsoid; \
	npm install; \
	find /usr/local/parsoid -iname '.git*' | xargs rm -rf
COPY ./includes/misc/parsoid/parsoid.initd /etc/init.d/parsoid
COPY ./includes/misc/parsoid/config.yaml /usr/local/parsoid/
COPY ./includes/misc/parsoid/localsettings.js /usr/local/parsoid/
COPY ./includes/misc/pingback/pingback.js /opt/docker/
RUN chmod +x /etc/init.d/parsoid
RUN cd /tmp; \
	wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2; \
	tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2; \
	mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin; \
	chmod +x /usr/local/bin/phantomjs; \
	rm -rf /tmp/phantomjs-2.1.1-linux-x86_64; \
	rm -rf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN sed -i 's/^max_execution_time.*$/max_execution_time = 600/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^post_max_size.*$/post_max_size = 128M/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^upload_max_filesize.*$/upload_max_filesize = 128M/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;date.timezone.*$/date.timezone = Europe\/Berlin/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^memory_limit*$/memory_limit = 512M/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.enable=.*$/opcache.enable=1/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.memory_consumption.*$/opcache.memory_consumption=512/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.max_accelerated_files.*$/opcache.max_accelerated_files=1000000/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.validate_timestamps.*$/opcache.validate_timestamps=1/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.revalidate_freq.*$/opcache.revalidate_freq=2/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;opcache.optimization_level.*$/opcache.optimization_level=0x7FFF9FFF/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^zlib.output_compression.*$/zlib.output_compression=On/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/^;zlib.output_compression_level.*$/zlib.output_compression_level=9/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/-m 64/-m 512/g' /etc/memcached.conf; \
	sed -i 's/error_reporting =.*/error_reporting=E_ALL ^ E_NOTICE/g' /etc/php/7.2/fpm/php.ini; \
	sed -i 's/error_reporting =.*/error_reporting=E_ALL ^ E_NOTICE/g' /etc/php/7.2/cli/php.ini; \
	echo "JAVA_OPTIONS=\"\-Xms512m -Xmx1024m -Djetty.home=127.0.0.1\"" >> /etc/default/jetty9; \
	mkdir /run/php; \
	chown -Rf www-data:www-data /run/php
RUN	apt-get -y purge build-essential; \
	apt-get -y auto-remove; \
	apt-get -y clean; \
	apt-get -y autoclean
EXPOSE 80 443
ENTRYPOINT /opt/docker/init.sh
