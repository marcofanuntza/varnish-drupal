FROM ubuntu:latest 
MAINTAINER Marco Fanuntza <marco.fanuntza@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
##
#######
ENV OWNER_USER            varnish
ENV OWNER_USER_UID        2000
ENV OWNER_GROUP           varnish
ENV OWNER_GROUP_GID       2000
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN groupadd --gid ${OWNER_GROUP_GID} -r ${OWNER_GROUP} &&  useradd -r --uid ${OWNER_USER_UID} -g ${OWNER_GROUP} ${OWNER_USER}
#Update
RUN apt-get update && apt-get -y upgrade 
##
#Varnish install
RUN apt-get -y install varnish --no-install-recommends 
##
#Apache2 & PHP install
RUN apt-get -y install apache2 php5 libapache2-mod-php5 php5-mysql php5-pgsql --no-install-recommends 
##
#Others
RUN apt-get -y install openssh-server supervisor mysql-client postgresql-client curl vim drush --no-install-recommends && rm -r /var/lib/apt/lists/*
##
#Drupal install
RUN cd /var/www && curl -O http://ftp.drupal.org/files/projects/drupal-7.41.tar.gz && tar -xzvf drupal-7.41.tar.gz && rm drupal-7.41.tar.gz && mv drupal-7.41/* drupal-7.41/.htaccess ./ && mv drupal-7.41/.gitignore ./ && rmdir drupal-7.41 && chown -R www-data:www-data /var/www 
##
#Post configurations
### Enable apache mods
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
RUN cd /etc/apache2/ && sed -i -e "s/*:80/*:8080/g" sites-enabled/000-default.conf && sed -i -e "s/80/8080/g" ports.conf
RUN a2enmod php5
RUN a2enmod rewrite


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 22 80 6082 8080
CMD ["/usr/bin/supervisord"]
#CMD ["varnishd", "-F", "-a", ":80", "-T", ":6082", "-f", "/etc/varnish/default.vcl", "-s", "malloc,1G"]

