#! /bin/sh
chown -R $PUID:$PGID /config

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        groupadd -g $PGID jellyfin_run
        GROUPNAME=jellyfin_run
fi

if [ ! $USERNAME ]
then
        useradd -m -G $GROUPNAME -u $PUID jellyfin_run
        USERNAME=jellyfin_run
fi

usermod -a -G video jellyfin_run
su $USERNAME -c '/usr/bin/jellyfin --datadir /config --cachedir /cache --ffmpeg /usr/share/jellyfin-ffmpeg/ffmpeg'