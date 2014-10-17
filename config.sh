#!/bin/sh

# SETTINGS
# Please check this settings. Without changing the
# user and group your installation will not work!
##

LOCATION=""         # Directory of PMA installation. Without a slash at the end. For example: LOCATION="/var/www"
PMA=""              # Name of the PMA folder. For example: pma or phpMyAdmin
LANGUAGE=""         # Language of PMA. Leave it blank for all languages or specify a language pack, for example: english
USER=""             # User of files
GROUP=""            # Group of files
CTYPE="tar.bz2"     # Compression type. default "tar.bz2". zip or tar.gz are possible, as well.
LOGLEVEL=1          # set 0 for quiet mode (no output)
                    # set 1 to output warnings (DEFAULT)
                    # set 2 to output all messages
VERSIONLINK="http://www.phpmyadmin.net/home_page/version.php"
FORCE="off"