# docker-nagios4

This is a docker image that will give you a naked Ubuntu 14.04 image with
Nagios4 (and apache2) installed.

It allows you to configure how Apache and Nagios are installed using ENV
variabled.

## Config Options

```docker
ENV NAGIOS_VERSION 4.0.8
ENV NAGIOS_PLUGINS_VERSION 2.0.3
ENV NAGIOS_NRPE_VERSION 2.15

ENV WORK_DIR /tmp

ENV NAGIOS_HOME /opt/nagios
ENV NAGIOS_USER nagios
ENV NAGIOS_GROUP nagios
ENV NAGIOS_CMDGROUP nagioscmd
ENV NAGIOSADMIN_USER nagiosadmin
ENV NAGIOSADMIN_PASS nagios
ENV NAGIOS_TIMEZONE US/Eastern
ENV NAGIOS_WEB_DIR $NAGIOS_HOME/share

ENV APACHE_RUN_USER nagios
ENV APACHE_RUN_GROUP nagios
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
```
