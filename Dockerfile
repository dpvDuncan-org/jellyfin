# syntax=docker/dockerfile:1
ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}debian:bookworm-slim

ENV PUID=0
ENV PGID=0

RUN mkdir -p /cache /config
RUN chmod 777 /cache /config
RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update -qq && apt-get dist-upgrade -qq && apt-get autoremove -qq && apt-get autoclean -qq
#RUN apt-get install -qq apt-transport-https at libfl2 libass9 libbluray2 libdrm2 libfontconfig1 libfreetype6 libfribidi0 libmp3lame0 libopus0 libtheora0 libva-drm2 libva2 libvdpau1 libvorbis0a libvorbisenc2 libwebp6 libwebpmux3 libx11-6 libx264-155 libx265-165 libzvbi0
RUN apt-get install -qq apt-transport-https apt-utils wget gnupg at libfontconfig1 libfreetype6 libssl3
RUN wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | apt-key add -
RUN echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian bookworm main" | tee /etc/apt/sources.list.d/jellyfin.list
RUN apt-get update -qq && apt-get install jellyfin jellyfin-ffmpeg6 -qq
RUN if [ "$( dpkg --print-architecture )" == 'amd64' ]; then apt-get install i965-va-driver mesa-va-drivers -qq; fi
RUN apt-get purge -qq wget gnupg && apt-get autoremove -qq && apt-get autoclean -qq
COPY scripts/start.sh /start.sh
RUN chmod 777 /start.sh
RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

EXPOSE 8096

VOLUME /config

ENTRYPOINT /start.sh
