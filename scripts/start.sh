#! /bin/sh
chown -R $PUID:$PGID /config

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ "$PRID" ]
then
        RENDERGROUP=$(getent passwd $PRID | cut -d: -f1)
        if [ ! $GROUPNAME ]
        then
                groupadd -g $PGID jellyfin_render
                RENDERGROUP=jellyfin_render
        fi
fi

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

if [ -d /opt/vc/lib ]
then
        ldconfig /opt/vc/lib/
fi

usermod -a -G video jellyfin_run

if [ "$PRID" ]
then
        usermod -a -G $RENDERGROUP jellyfin_run
fi

su $USERNAME -c '/usr/bin/jellyfin -w /usr/share/jellyfin/web -d /config -C /cache --ffmpeg /usr/share/jellyfin-ffmpeg/ffmpeg'