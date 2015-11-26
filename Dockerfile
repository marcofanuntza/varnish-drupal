FROM ubuntu:latest 
MAINTAINER Marco Fanuntza <marco.fanuntza@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
#Update
RUN apt-get update && apt-get -y upgrade 
##
#Install Varnish Apache Php
RUN apt-get -y install varnish apache2 php5 libapache2-mod-php5 php5-mysql php5-pgsql mysql-client postgresql-client curl vim drush --no-install-recommends && rm -r /var/lib/apt/lists/* 
##
#Drupal install
RUN cd /var/www && curl -O http://ftp.drupal.org/files/projects/drupal-7.41.tar.gz && tar -xzvf drupal-7.41.tar.gz && rm drupal-7.41.tar.gz && mv drupal-7.41/* drupal-7.41/.htaccess ./ && mv drupal-7.41/.gitignore ./ && rmdir drupal-7.41 && chown -R www-data:www-data /var/www 
##
#Post configurations
### Enable apache mods
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
RUN cd /etc/apache2/ && sed -i -e "s/*:80/*:8080/g" sites-enabled/000-default.conf && sed -i -e "s/80/8080/g" ports.conf
RUN cd /etc/default/ && sed -i -e "s/6081/80/g" varnish 
RUN a2enmod php5
RUN a2enmod rewrite

ENV VCL_CONFIG      /etc/varnish/default.vcl
ENV CACHE_SIZE      64m
ENV VARNISHD_PARAMS -p default_ttl=3600 -p default_grace=3600
COPY start.sh /
CMD /start.sh  

EXPOSE 80 6082 8080

