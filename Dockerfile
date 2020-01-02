ARG BASE_IMAGE_PREFIX

FROM multiarch/qemu-user-static as qemu

FROM ${BASE_IMAGE_PREFIX}debian:buster-slim

COPY --from=qemu /usr/bin/qemu-*-static /usr/bin/

ENV PUID=0
ENV PGID=0

FROM balenalib/rpi-raspbian

RUN mkdir -p /cache /config
RUN chmod 777 /cache /config
RUN apt-get update -qq && apt-get dist-upgrade -qq && apt-get autoremove -qq && apt-get autoclean -qq
#RUN apt-get install -qq apt-transport-https at libfl2 libass9 libbluray2 libdrm2 libfontconfig1 libfreetype6 libfribidi0 libmp3lame0 libopus0 libtheora0 libva-drm2 libva2 libvdpau1 libvorbis0a libvorbisenc2 libwebp6 libwebpmux3 libx11-6 libx264-155 libx265-165 libzvbi0
RUN apt-get install -qq apt-transport-https wget
RUN wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | sudo apt-key add -
RUN echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian $( lsb_release -c -s ) main" | tee /etc/apt/sources.list.d/jellyfin.list
RUN apt-get update -qq && apt-get install jellyfin jellyfin-ffmpeg
RUN apt-get purge -qq wget && apt-get autoremove -qq && apt-get autoclean -qq
COPY scripts/start.sh /start.sh
RUN chmod 777 /start.sh
RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /usr/bin/qemu-*-static

EXPOSE 8096

VOLUME /config

ENTRYPOINT /start.sh