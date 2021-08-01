#!/usr/bin/env sh

##
# PHPMYADMIN UPDATE SCRIPT
# https://github.com/Dennis14e/pma-updatescript
# Author: Stefan Schulz-Lauterbach
# Author: Michael Riehemann
# Author: Igor Buyanov
# Author: Dennis Neufeld
##

##
# SETTINGS
# Copy .env.example to .env to set your settings.
# Don't change anything in this script.
##


SCRIPT_DIR=$(dirname "$0")


# Output help
usage() {
    echo "usage: sh pma-update.sh [-hvf] [-r version]"
    echo "-h            this help"
    echo "-v            output all warnings"
    echo "-f            force download, even if this version is installed already"
    echo "-r version    choose a different version than the latest."
}

# Output warnings
log() {
    if [ $LOGLEVEL -gt 0 ]
    then
        echo "$@"
    fi
}


# Output additional messages
info() {
    if [ $LOGLEVEL -eq 2 ]
    then
        echo "$@"
    fi
}


# Load .env file
if [ ! -f "${SCRIPT_DIR}/.env" ]
then
    log "Did not find .env settings file."
fi

. "${SCRIPT_DIR}/.env"


# Options
params="$(getopt -o hvfr: -l help --name "$cmdname" -- "$@")"

if [ $? -ne 0 ]
then
    usage
fi

eval set -- "$params"
unset params

while true
do
    case "$1" in
        -v)
            LOGLEVEL=2
            ;;
        -f)
            FORCE=1
            ;;
        -r)
            VERSION="$2"
            shift
            ;;
        -h|--help)
            usage
            exit
            ;;
        --)
            shift
            break
            ;;
        *)
            usage
            ;;
    esac
    shift
done


# Check INSTALL_LOCATION, UPDATE_LOCATION settings
if [ -z "$INSTALL_LOCATION" -o -z "$UPDATE_LOCATION" ]
then
    log "Please, check your settings. The variables INSTALL_LOCATION, UPDATE_LOCATION are mandatory!"
    exit 1
fi

if [ ! -d "$INSTALL_LOCATION" -o ! -d "$UPDATE_LOCATION" ]
then
    log "Please, check your settings. The locations INSTALL_LOCATION and/or UPDATE_LOCATION does not exist!"
    exit 1
fi


# Get the local installed version
if [ -f "${INSTALL_LOCATION}/README" ]
then
    VERSIONLOCAL=$(sed -n 's/^Version \(.*\)$/\1/p' "${INSTALL_LOCATION}/README")
    info "Found local installation version" $VERSIONLOCAL
else
    log "Did not found a working installation. Please, check the script settings."
    exit 1
fi



# If $USER or $GROUP empty, read from installed phpMyAdmin
if [ -z "$USER" ]
then
    USER=$(stat -c "%U" "${INSTALL_LOCATION}/index.php")
fi
if [ -z "$GROUP" ]
then
    GROUP=$(stat -c "%G" "${INSTALL_LOCATION}/index.php")
fi


# Check user/group settings
if [ -z "$USER" -o -z "$GROUP" ]
then
    log "Please, check your settings. Set USER and GROUP, please!"
    exit 1
fi

if [ -z "$LANGUAGE" ]
then
    LANGUAGE="all-languages"
fi



# Get latest version
if [ -z "$VERSION" ]
then
    VERSION=$(wget -q -O - "$VERSIONLINK" | sed -ne '1p')
fi

# Check the versions
if [ -z "$VERSION" ]
then
    log "Something went wrong while getting the version of phpMyAdmin. :("
    log "Maybe this link here is dead: $VERSIONLINK"
    exit 1
fi

if [ "$VERSION" = "$VERSIONLOCAL" ]
then
    info "phpMyAdmin $VERSIONLOCAL is already installed!"
    if [ "$FORCE" -ne 1 ]
    then
        exit 0
    fi
    info "I will install it anyway."
fi



# Set output parameters
WGETLOG="-q"
VERBOSELOG=""
if [ "$CTYPE" = "tar.gz" ]
then
    TARLOG="xzf"
elif [ "$CTYPE" = "tar.bz2" ]
then
    TARLOG="xjf"
fi

if [ $LOGLEVEL -eq 2 ]
then
    WGETLOG="-v"
    VERBOSELOG="-v"
    TARLOG=${TARLOG}v
fi


# Start update
cd "$UPDATE_LOCATION"
CWD_LOCATION=`pwd`

if [ "$CWD_LOCATION" != "$UPDATE_LOCATION" ]
then
    log "An error occured while changing the directory. Please check your settings! Your given directory: $UPDATE_LOCATION"
    exit 1
fi


VERSION_PATH="phpMyAdmin-${VERSION}-${LANGUAGE}"
wget "$WGETLOG" "${DOWNLOADURL}/${VERSION}/${VERSION_PATH}.${CTYPE}"

if [ ! -f "${VERSION_PATH}.${CTYPE}" ]
then
    log "An error occured while downloading phpMyAdmin. Downloading unsuccessful from: ${DOWNLOADURL}/${VERSION}/${VERSION_PATH}.${CTYPE}."
    exit 1
fi


# Extract tar
tar $TARLOG "${VERSION_PATH}.${CTYPE}"

if [ $? -ne 0 ]
then
    log "An error occured while extracting phpMyAdmin. Extracting unsuccessful from: ${VERSION_PATH}.${CTYPE}."
    exit 1
fi

# Remove downloaded tar
rm $VERBOSELOG "${VERSION_PATH}.${CTYPE}"

# Copy config file
cp $VERBOSELOG "${INSTALL_LOCATION}/config.inc.php" "${UPDATE_LOCATION}/${VERSION_PATH}/"

# Remove setup-folder for security issues
rm -R $VERBOSELOG "${UPDATE_LOCATION}/${VERSION_PATH}/setup"

if [ $DELETE -eq 1 ]
then
    # Remove examples-folder
    rm -R $VERBOSELOG "${UPDATE_LOCATION}/${VERSION_PATH}/examples"
fi

# Delete installation
rm -R $VERBOSELOG "$INSTALL_LOCATION"

# Move updated installation to original installation location
mv $VERBOSELOG "${UPDATE_LOCATION}/${VERSION_PATH}" "$INSTALL_LOCATION"

# Set permissions
chown -R $VERBOSELOG $USER:$GROUP "$INSTALL_LOCATION"

log "PhpMyAdmin successfully updated from version $VERSIONLOCAL to $VERSION in $INSTALL_LOCATION. Enjoy!"
