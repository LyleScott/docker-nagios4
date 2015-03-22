# docker-nagios4

This docker image will give you an Ubuntu 14.04 image with Nagios4
(and apache2) installed.

## Quick Start

```bash
docker pull lylescott/nagios4
docker run -i -t -p 9443:443 lylescott/nagios4
```

Then, visit http://dockerip:9443 (and accept the self-signed cert)

### Customize with a Dockerfile
```bash
FROM lylescott/nagios4
MAINTAINER Lyle Scott, III <lyle@digitalfoo.net>

ENV NAGIOS_ADMIN_EMAIL              lyle@digitalfoo.net
ENV NAGIOS_MAIL_SERVER              gmailrelay
ENV NAGIOSADMIN_USER                ls3 
ENV NAGIOSADMIN_PASS                nagios1!

USER root

# Set timezone
echo America/New_York > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Nagios config
RUN echo > ${NAGIOS_HOME}/etc/objects/localhost.cfg
RUN mkdir ${NAGIOS_HOME}/etc/docker
COPY nagios_cfgs/* ${NAGIOS_HOME}/etc/docker/
RUN echo "cfg_dir=/opt/nagios/etc/docker" >> /opt/nagios/etc/nagios.cfg
RUN sed -i "s|\(^        email                           \).*|\1$NAGIOS_ADMIN_EMAIL|" ${NAGIOS_HOME}/etc/objects/contacts.cfg
RUN sed -i 's|/bin/mail|/usr/bin/mail|' /opt/nagios/etc/nagios.cfg
RUN htpasswd -c -b -s ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}

# Replace the vhost config with your own
ADD vhost.conf /etc/apache2/sites-available/nagios.conf

# Postfix config...relay
RUN sed -i "s/myhostname =.*/myhostname = `hostname`/" /etc/postfix/main.cf &&\
    sed -i "s/relayhost =.*/relayhost = ${NAGIOS_MAIL_SERVER}/" /etc/postfix/main.cf

RUN /etc/init.d/apache2 restart
```

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
