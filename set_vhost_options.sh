#!/bin/bash

sed -i \                                                                  
    "s|%%APACHE_VHOST_SERVERNAME%%|${APACHE_VHOST_SERVERNAME}|" \         
    /etc/apache2/sites-available/nagios.conf                          
sed -i \                                                                  
    "s|%%APACHE_VHOST_SERVERADMIN%%|${APACHE_VHOST_SERVERADMIN}|" \       
    /etc/apache2/sites-available/nagios.conf                          
sed -i \                                                                  
    "s|%%APACHE_VHOST_PORT%%|${APACHE_VHOST_PORT}|" \                     
    /etc/apache2/sites-available/nagios.conf                          
sed -i \                                                                  
    "s|%%APACHE_VHOST_USESSL%%|${APACHE_VHOST_USESSL}|" \                 
    /etc/apache2/sites-available/nagios.conf                              

a2ensite nagios
