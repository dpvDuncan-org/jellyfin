#!/bin/sh
set -e

PUID=${PUID:-0}
PGID=${PGID:-0}

# Création ou récupération du groupe principal
GROUPNAME=$(getent group "$PGID" | cut -d: -f1 || true)
if [ -z "$GROUPNAME" ]; then
    GROUPNAME="jellyfin_run"
    groupadd -g "$PGID" "$GROUPNAME"
fi

# Création ou récupération de l'utilisateur
USERNAME=$(getent passwd "$PUID" | cut -d: -f1 || true)
if [ -z "$USERNAME" ]; then
    USERNAME="jellyfin_run"
    useradd -m -g "$GROUPNAME" -u "$PUID" "$USERNAME"
else
    usermod -g "$GROUPNAME" "$USERNAME"
fi

# Ajout au groupe video pour l'accélération matérielle
if getent group video >/dev/null 2>&1; then
    usermod -a -G video "$USERNAME"
fi

# Gestion du groupe render (PRID) si défini
if [ -n "$PRID" ]; then
    RENDERGROUP=$(getent group "$PRID" | cut -d: -f1 || true)
    if [ -z "$RENDERGROUP" ]; then
        RENDERGROUP="jellyfin_render"
        groupadd -g "$PRID" "$RENDERGROUP"
    fi
    usermod -a -G "$RENDERGROUP" "$USERNAME"
fi

# Mise à jour des bibliothèques VideoCore (Raspberry Pi) si présentes
if [ -d /opt/vc/lib ]; then
    ldconfig /opt/vc/lib/
fi

# Application des permissions sur /config et /cache
chown -R "$PUID:$PGID" /config /cache

# Démarrage de Jellyfin en remplaçant le processus shell (gestion propre de SIGTERM)
exec su -p -s /bin/sh "$USERNAME" -c '/usr/bin/jellyfin -w /usr/share/jellyfin/web -d /config -C /cache --ffmpeg /usr/share/jellyfin-ffmpeg/ffmpeg'
