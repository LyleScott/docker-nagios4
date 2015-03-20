# docker-nagios4

This docker image will give you an Ubuntu 14.04 image with Nagios4
(and apache2) installed.

It allows you to configure how Apache and Nagios are installed using ENV
variables.

## Config Options

```bash
ENV NAGIOS_VERSION                  4.0.8
ENV NAGIOSPLUGINS_VERSION           2.0.3
ENV NRPE_VERSION                    2.15

ENV WORK_DIR                        /tmp
ENV SYSTEM_TIMEZONE                 America/New_York

ENV NAGIOS_HOME                     /opt/nagios
ENV NAGIOS_USER                     nagios
ENV NAGIOS_GROUP                    nagios
ENV NAGIOS_CMDGROUP                 nagioscmd
ENV NAGIOSADMIN_USER                nagiosadmin
ENV NAGIOSADMIN_PASS                nagios
ENV NAGIOS_TIMEZONE                 US/Eastern
ENV NAGIOS_WEB_DIR                  $NAGIOS_HOME/share
ENV NAGIOS_ADMIN_EMAIL              admin@example.com

ENV APACHE_VHOST_SERVERNAME         www.path.to.nagios.com
ENV APACHE_VHOST_SERVERADMIN        admin@example.com
ENV APACHE_VHOST_PORT               443
ENV APACHE_RUN_USER                 nagios
ENV APACHE_RUN_GROUP                nagios
ENV APACHE_LOG_DIR                  /var/log/apache2
ENV APACHE_PID_FILE                 /var/run/apache2.pid
ENV APACHE_RUN_DIR                  /var/run/apache2
ENV APACHE_LOCK_DIR                 /var/lock/apache2
ENV APACHE_SERVERNAME               localhost
ENV APACHE_SERVERALIAS              docker.localhost
ENV APACHE_ERROR_LOG                /dev/stdout
ENV APACHE_LOG_LEVEL                error 

ENV NAGIOS_SSLCERT_COUNTRY          US
ENV NAGIOS_SSLCERT_STATE            mystate
ENV NAGIOS_SSLCERT_LOCATION         mylocation
ENV NAGIOS_SSLCERT_ORGANIZATION     myorganization
ENV NAGIOS_SSLCERT_CNAME            ${APACHE_VHOST_SERVERNAME}

ENV UBUNTU_APTGET_MIRROR            mirror://mirrors.ubuntu.com/mirrors.txt
```

## Quick Start

```bash
docker pull lylescott/nagios4
docker run -i -t -p 9443:443 lylescott/nagios4
```

Then, visit http://dockerip:9443 (and accept the self-signed cert)

### Customize with a Dockerfile
```bash
FROM lylescott/nagios4
MAINTAINER Your Name <your@email.com>

USER root

# Copy over your Nagios4 configs.
COPY cfg/* ${NAGIOS_HOME}/etc/docker/
```

The "cfg" directory should contain all your custom Nagios config files. Any
filename ending in .cfg will be automatically picked up by Nagios. The files
can be nested in any directory stucture.

#### Example Nagios cfg File

In reality, you would probably want your template, service, host, etc configs
all split out into their own files or nested in an organized directory
structure.

I included a super simple example (without custom commands)... read up on
Nagios4 documentation for full details on how to creating fancy config files.

```
# Host Template
define host {
    name                            linux-box
    use                             generic-host
    check_period                    24x7
    check_interval                  5
    retry_interval                  1
    max_check_attempts              10
    notification_period             24x7
    register                        0
    contacts                        nagiosadmin
}

# Hosts
define host {
    use                             linux-box
    host_name                       google.com
    alias                           google.com
    address                         216.58.219.142
}

#Services
define service {
    use                             generic-service
    host_name                       google.com
    service_description             Host Alive
    check_command                   check-host-alive
}
define service {
    use                             generic-service
    host_name                       google.com
    service_description             HTTP
    check_command                   check_http
}
```


## Links
https://github.com/LyleScott/docker-nagios4
https://registry.hub.docker.com/u/lylescott/nagios4/
