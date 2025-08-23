FROM ubuntu:24.04 as bareos-base

ARG distro

ENV DEBIAN_FRONTEND noninteractive
ENV ADD_BAREOS_REPO_URL "https://download.bareos.org/current/$distro/add_bareos_repositories.sh"
ENV ADD_BAREOS_REPO_PATH /tmp/add_bareos_repositories.sh

RUN if [ -z "$distro" ]; then \
    echo "Error: distro is required but not set."; \
    exit 1; \
fi

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    vim-tiny \
    tzdata

RUN curl -Ls "$ADD_BAREOS_REPO_URL" -o "$ADD_BAREOS_REPO_PATH" && bash "$ADD_BAREOS_REPO_PATH"

COPY scripts/make_bareos_config.sh /scripts/make_bareos_config.sh


# --------------- bareos-dir ---------------

FROM bareos-base as bareos-dir

RUN apt-get update && apt-get install -y \
    bareos-database-postgresql \
    bareos-director \
    bareos-bconsole

EXPOSE 9101

COPY scripts/director-entrypoint.sh /scripts/director-entrypoint.sh
RUN chmod u+x /scripts/director-entrypoint.sh

ENTRYPOINT ["/scripts/director-entrypoint.sh"]
CMD ["/usr/sbin/bareos-dir", "-f"]


# --------------- bareos-webui ---------------

FROM bareos-base as bareos-webui

RUN apt-get update && apt-get install -y \
    bareos-webui \
    nginx

EXPOSE 9100

COPY webui_nginx_default /etc/nginx/sites-enabled/default
COPY scripts/webui-entrypoint.sh /scripts/webui-entrypoint.sh
RUN chmod u+x /scripts/webui-entrypoint.sh

ENTRYPOINT ["/scripts/webui-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]


# --------------- bareos-sd ---------------

FROM bareos-base as bareos-sd

RUN apt-get update && apt-get install -y \
    bareos-storage

EXPOSE 9103

COPY scripts/sd-entrypoint.sh /scripts/sd-entrypoint.sh
RUN chmod u+x /scripts/sd-entrypoint.sh

ENTRYPOINT ["/scripts/sd-entrypoint.sh"]
CMD ["/usr/sbin/bareos-sd", "-f"]


# --------------- bareos-fd ---------------

FROM bareos-base as bareos-fd

RUN apt-get update && apt-get install -y \
    bareos-filedaemon

EXPOSE 9102

COPY scripts/fd-entrypoint.sh /scripts/fd-entrypoint.sh
RUN chmod u+x /scripts/fd-entrypoint.sh

ENTRYPOINT ["/scripts/fd-entrypoint.sh"]
CMD ["/usr/sbin/bareos-fd", "-f"]

