ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}debian:trixie-slim

ENV PUID=0
ENV PGID=0
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /cache /config /etc/apt/keyrings && \
    chmod 777 /cache /config

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update -qq && \
    apt-get dist-upgrade -qq -y && \
    apt-get install -qq -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg \
        at \
        libfontconfig1 \
        libfreetype6 \
        libssl3t64

RUN wget -qO - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg && \
    cat <<EOF > /etc/apt/sources.list.d/jellyfin.sources
Types: deb
URIs: https://repo.jellyfin.org/debian
Suites: trixie
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/jellyfin.gpg
EOF

RUN apt-get update -qq && \
    apt-get install -qq -y jellyfin && \
    if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        apt-get install -qq -y i965-va-driver intel-media-va-driver mesa-va-drivers; \
    fi

RUN apt-get purge -qq -y wget gnupg && \
    apt-get autoremove -qq -y && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 8096
VOLUME /config

ENTRYPOINT ["/start.sh"]
