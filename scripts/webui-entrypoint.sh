#!/usr/bin/env bash

/scripts/make_bareos_config.sh /etc_bareos /etc/bareos-webui

php-fpm8.3

exec "$@"
