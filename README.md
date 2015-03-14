# docker-nagios4

This is a docker image that will give you a naked Ubuntu 14.04 image with
Nagios4 (and apache2) installed.

It allows you to configure how Apache and Nagios are installed using ENV
variables.

## Config Options

```bash
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

## Quick Start
```bash
docker build -t lylescott/nagios .
docker run -i -t -p 9443:443 lylescott/nagios
```

Visit http://dockerip:9443 (and accept the self-signed cert)

## Customize Your Image
THIS DOESNT WORK YET. This image will be in the docker repos soon, though.

```bash
FROM lylescott/nagios

<your customiziations here>
```
