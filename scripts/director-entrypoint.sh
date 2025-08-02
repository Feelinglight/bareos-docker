#!/usr/bin/env bash

/scripts/make_bareos_config.sh /etc_bareos /etc/bareos

export PGHOST=${BAREOS__DB_HOST}
export PGUSER=${POSTGRES_ADMIN_USER}
export PGPASSWORD=${POSTGRES_ADMIN_PASSWORD}

[[ -z "${BAREOS__DB_INIT}" ]] && BAREOS__DB_INIT='false'

if [ "${BAREOS__DB_INIT}" == 'true' ]; then
  echo "Bareos DB init"
  echo "Bareos DB init: Create user ${BAREOS__DB_NAME}"
  psql -c "create user ${BAREOS__DB_NAME} with createdb createrole login;"
  echo "Bareos DB init: Set user password"
  psql -c "alter user ${BAREOS__DB_NAME} password '${BAREOS__DB_PASSWORD}';"

  /usr/lib/bareos/scripts/create_bareos_database
  /usr/lib/bareos/scripts/make_bareos_tables
  /usr/lib/bareos/scripts/grant_bareos_privileges

  touch /etc/bareos/bareos-db.control
fi

[[ -z "${BAREOS__DB_UPDATE}" ]] && BAREOS__DB_UPDATE='false'

if [ "${BAREOS__DB_UPDATE}" == 'true' ]; then
  echo "Bareoos DB update"
  echo "Bareoos DB update: Update tables"
  /usr/lib/bareos/scripts/update_bareos_tables
  echo "Bareoos DB update: Grant privileges"
  /usr/lib/bareos/scripts/grant_bareos_privileges
fi

exec "$@"
