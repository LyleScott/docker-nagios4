# docker-nagios4

This docker image will give you an Ubuntu 14.04 image with Nagios4
(and apache2) installed.

It allows you to configure how Apache and Nagios are installed using ENV
variables.

## Overridable Config Options

```bash
# The Linux system's timezone
ENV SYSTEM_TIMEZONE                 America/New_York

# The user and pass for the password prompt to access Nagios
ENV NAGIOSADMIN_USER                nagiosadmin
ENV NAGIOSADMIN_PASS                nagios

# Nagios (apache) vhost options.
ENV APACHE_VHOST_SERVERNAME         nagios.example.com
ENV APACHE_VHOST_SERVERADMIN        lyle@nagios.example.com
ENV APACHE_VHOST_PORT               443
# options: On Off
ENV APACHE_VHOST_USESSL             On
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

```bash
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
