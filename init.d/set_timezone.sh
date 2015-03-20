#!/bin/bash

echo ${SYSTEM_TIMEZONE} > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
