#!/usr/bin/env sh
##
# PHPMYADMIN UPDATE SCRIPT
# https://github.com/Dennis14e/pma-updatescript
##

SCRIPT_DIR=$(dirname "$0")

# SETTING
CRONPATH="/etc/cron.daily/pma-update"

# GO
installcron() {
    echo > "$CRONPATH"
    echo "#!/usr/bin/env sh" >> "$CRONPATH"
    echo "sh \"${SCRIPT_DIR}/pma-update.sh\"" >> "$CRONPATH"
    chmod 755 "$CRONPATH"

    echo "Cronjob for phpMyAdmin Update-Script installed."
}

if [ -f "$CRONPATH" ]
then
    echo "Cronjob for pma-update already exists. Do you want to renew it? [y|N]"
    read answer
    if [ "$answer" = y -o "$answer" = Y ]
    then
        rm "$CRONPATH"
    else
        echo "Ok, I did nothing!"
        exit 0
    fi
fi

installcron
