#!/bin/bash

set -e

# Этой версией будут тэгнуты докер образы
BAREOS_VERSION="24.0.5-pre32.7c5f79a1e"
# Дистрибутив, для которого собраны пакеты bareos
DISTRO="xUbuntu_24.04"

# NOCACHE="--no-cache"
NOCACHE=

bareos_daemons="bareos-dir bareos-webui bareos-fd bareos-sd"

for daemon in $bareos_daemons; do
  # shellcheck disable=SC2086
  docker build ${NOCACHE} \
    --build-arg "distro=$DISTRO" \
    --target "${daemon}" \
    -t "feelinglight/${daemon}:${BAREOS_VERSION}" \
    -t "feelinglight/${daemon}:latest" \
    .
done

# shellcheck disable=SC2046
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

for daemon in $bareos_daemons; do
  docker push "feelinglight/${daemon}:${BAREOS_VERSION}"
  docker push "feelinglight/${daemon}:latest"
done
