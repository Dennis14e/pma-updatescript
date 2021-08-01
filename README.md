# phpMyAdmin updatescript for your shell
This script will update your current phpMyAdmin to the latest version directly from your shell.

## Requirements
- wget
- tar

## Installation
Copy/clone this repository to any location of your machine.
IMPORTANT: You need to copy `.env.example` to `.env` and edit the settings inside the file `.env`.

If you want to install a cronjob, run

```shell
sh install-cronjob.sh
```

## Settings
Open the file `.env` and edit the variables INSTALL_LOCATION, UPDATE_LOCATION.
If you want, change the compression type - "tar.gz" and "tar.bz2" are possible.

## Usage
For updating phpMyAdmin to the latest version, execute the shell script like this:

```shell
sh pma-update.sh
```

If you want to update to a specific version

```shell
sh pma-update.sh -r 3.5.0
```

### More options
    sh pma-update.sh [-hvf] [-r version]
    -h    this help
    -v    output all warnings
    -f    force download, even if this version is installed already
    -r version    choose a different version than the latest.
