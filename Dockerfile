FROM ubuntu:14.04
MAINTAINER Lyle Scott, III "lyle@digitalfoo.net"

# Credits that helped buld this docker image::
# https://raymii.org/s/tutorials/Nagios_Core_4_Installation_on_Ubuntu_12.04.html
# https://github.com/cpuguy83/docker-nagios

ENV NAGIOS_VERSION 4.0.8
ENV NAGIOSPLUGINS_VERSION 2.0.3
ENV NRPE_VERSION 2.15

ENV WORK_DIR /tmp
ENV SYSTEM_TIMEZONE America/New_York

ENV NAGIOS_HOME /opt/nagios
ENV NAGIOS_USER nagios
ENV NAGIOS_GROUP nagios
ENV NAGIOS_CMDGROUP nagioscmd
ENV NAGIOSADMIN_USER nagiosadmin
ENV NAGIOSADMIN_PASS nagios
ENV NAGIOS_TIMEZONE US/Eastern
ENV NAGIOS_WEB_DIR $NAGIOS_HOME/share
ENV NAGIOS_ADMIN_EMAIL admin@example.com

ENV APACHE_VHOST_SERVERNAME www.path.to.nagios.com
ENV APACHE_VHOST_SERVERADMIN admin@example.com
ENV APACHE_VHOST_PORT 443
ENV APACHE_RUN_USER nagios
ENV APACHE_RUN_GROUP nagios
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_ERROR_LOG /dev/stdout
ENV APACHE_LOG_LEVEL error 

ENV DEBIAN_FRONTEND noninteractive

USER root

#>> Set system timezone
RUN echo ${SYSTEM_TIMEZONE} > /etc/timezone &&\
    dpkg-reconfigure -f noninteractive tzdata

#>> Gather all the needed packages.
RUN apt-get update
RUN apt-get install -q -y apache2 supervisor libapache2-mod-php5 build-essential libgd2-xpm-dev libssl-dev wget apache2-utils libnet-snmp-perl libpq5 libradius1 libsensors4 libsnmp-base libtalloc2 libtdb1 libwbclient0 samba-common samba-common-bin smbclient snmp whois mrtg libmysqlclient15-dev libcgi-pm-perl librrds-perl libgd-gd2-perl checkinstall
RUN /etc/init.d/apache2 stop

#>> Copy over the supervisord config.
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#>> Add users and such.
RUN groupadd -g 3000 ${NAGIOS_GROUP}
RUN groupadd -g 3001 ${NAGIOS_CMDGROUP}
RUN useradd -u 3000 -g ${NAGIOS_GROUP} -G ${NAGIOS_CMDGROUP} -d ${NAGIOS_HOME} -c 'Nagios Admin' ${NAGIOS_USER}
RUN adduser www-data ${NAGIOS_CMDGROUP}

#>> Install Nagios4
RUN mkdir -p ${NAGIOS_HOME}/share/{stylesheets,images}
RUN mkdir -p ${WORK_DIR}/nagios4 &&\
    cd ${WORK_DIR}/nagios4 &&\
    wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-${NAGIOS_VERSION}.tar.gz &&\
    tar -xf nagios-${NAGIOS_VERSION}.tar.gz &&\
    cd nagios-${NAGIOS_VERSION} &&\
    ./configure \
        --prefix=${NAGIOS_HOME} \
        --with-nagios-user=${NAGIOS_USER} \
        --with-nagios-group=${NAGIOS_GROUP} \
        --with-command-user=${NAGIOS_USER} \
        --with-command-group=${NAGIOS_CMDGROUP} &&\
    make all &&\
    make install && make install-config && make install-commandmode &&\
    /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/conf-available/nagios.conf &&\
    ln -s /etc/apache2/conf-available/nagios.conf /etc/apache2/conf-enabled/nagios.conf
# Copy over custom config files (any file ending with .cfg will be picked up,
# including any nested files with the same pattern.)
RUN mkdir ${NAGIOS_HOME}/etc/docker
COPY cfg ${NAGIOS_HOME}/etc/docker/
RUN echo "cfg_dir=/opt/nagios/etc/docker" >> /opt/nagios/etc/nagios.cfg
RUN sed -i "s|\(^        email                           \).*|\1$NAGIOS_ADMIN_EMAIL|" ${NAGIOS_HOME}/etc/objects/contacts.cfg

#>> Install Nagios Plugins
RUN mkdir -p ${WORK_DIR}/nagios-plugins &&\
    cd ${WORK_DIR}/nagios-plugins &&\
    wget https://www.nagios-plugins.org/download/nagios-plugins-${NAGIOSPLUGINS_VERSION}.tar.gz &&\
    tar -xf nagios-plugins-${NAGIOSPLUGINS_VERSION}.tar.gz &&\
    cd nagios-plugins-${NAGIOSPLUGINS_VERSION} &&\
    ./configure \
        --prefix=${NAGIOS_HOME} \
        --with-nagios-user=${NAGIOS_USER} \
        --with-nagios-group=${NAGIOS_GROUP} \
        --with-openssl=/usr/bin/openssl \
        --enable-perl-modules \
        --enable-libtap &&\
    make &&\
    make install

#>> Install NRPE
RUN mkdir -p ${WORK_DIR}/nrpe &&\
    cd ${WORK_DIR}/nrpe &&\
    wget http://kent.dl.sourceforge.net/project/nagios/nrpe-2.x/nrpe-${NRPE_VERSION}/nrpe-${NRPE_VERSION}.tar.gz &&\
    tar -xf nrpe-${NRPE_VERSION}.tar.gz &&\
    cd nrpe-${NRPE_VERSION} &&\
    ./configure \
        --prefix=${NAGIOS_HOME} \
        --with-ssl=/usr/bin/openssl \
        --with-ssl-lib=/usr/lib/x86_64-linux-gnu &&\
    make &&\
    make install

#>> Install and Configure Apache
RUN sed -i "s|\(^ErrorLog \).*|\1${APACHE_ERROR_LOG}|" /etc/apache2/apache2.conf &&\
    sed -i "s|\(^LogLevel \).*|\1${APACHE_LOG_LEVEL}|" /etc/apache2/apache2.conf
# Generate a password to use with authentication via Apache. 
RUN htpasswd -b -c ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
RUN chown ${NAGIOS_USER}:${NAGIOS_CMDGROUP} ${NAGIOS_HOME}/etc/htpasswd.users
# Enable SSL module.
RUN a2enmod ssl
# Generate a SSL key for HTTPS access to Nagios web service.
RUN mkdir -p /etc/apache2/ssl &&\
    cd /etc/apache2/ssl &&\
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -out nagios.pem -keyout nagios.key \
        -subj "/C=US/ST=Florida/L=St Petersburg/O=LS3/CN=my.domain.com" 
# Create a place for the Nagios HTTP docs to live.
RUN mkdir -p ${NAGIOS_WEB_DIR}
RUN chown www-data:www-data ${NAGIOS_WEB_DIR}
# Enable CGI module.
RUN a2enmod cgi
# Disable default apache site.
RUN a2dissite 000-default
# Enable the Nagios virtual host we copied over.
ADD vhost.conf /etc/apache2/sites-available/nagios.conf &&\
    sed -i \
        "s/%%APACHE_VHOST_SERVERNAME%%/${APACHE_VHOST_SERVERNAME}" \
        /etc/apache2/sites-available/nagios.conf &&\
    sed -i \
        "s/%%APACHE_VHOST_SERVERADMIN%%/${APACHE_VHOST_SERVERADMIN}" \
        /etc/apache2/sites-available/nagios.conf &&\
    sed -i \
        "s/%%APACHE_VHOST_PORT%%/${APACHE_VHOST_PORT}" \
        /etc/apache2/sites-available/nagios.conf
RUN a2ensite nagios

#>> Cleanup
RUN apt-get autoclean -y &&\
    apt-get autoremove -y &&\
    apt-get rm -rf /tmp/* /var/lib/apt/lists/*

EXPOSE 443

ENTRYPOINT ["/usr/bin/supervisord"]
