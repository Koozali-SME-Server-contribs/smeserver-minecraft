#!/bin/bash
# Koozali SME SERVER msm hq configuration
# inspired by original install script

UPDATE_URL="https://raw.githubusercontent.com/msmhq/msm/master"
msm_dir="/opt/msm"
msm_user="minecraft"
msm_user_system=false
dl_dir="$(mktemp -d -t msm-XXX)"

# Outputs an MSM INSTALL log line
function install_log() {
    echo -e "\n\033[1;32mMSM INSTALL: $*\033[m"
}

# Outputs an MSM INSTALL ERROR log line and exits with status code 1
function install_error() {
    echo -e "\n\033[1;37;41mMSM INSTALL ERROR: $*\033[m"
    exit 1
}


# Fetches latest msm.conf, cron job, and init script
function download_latest_files() {
    if [ ! -d "$dl_dir" ]; then
        install_error "Temporary download directory was not created properly"
    fi

    install_log "Downloading latest MSM configuration file"
    sudo wget ${UPDATE_URL}/msm.conf \
        -O "$dl_dir/msm.conf.orig" || install_error "Couldn't download configuration file"

    install_log "Downloading latest MSM cron file"
    sudo wget ${UPDATE_URL}/cron/msm \
        -O "$dl_dir/msm.cron.orig" || install_error "Couldn't download cron file"

    install_log "Downloading latest MSM version"
    sudo wget ${UPDATE_URL}/init/msm \
        -O "$dl_dir/msm.init.orig" || install_error "Couldn't download init file"
}

# Updates rest of MSM using init script updater
function update_msm() {
    install_log "Asking MSM to update itself"
    sudo /usr/bin/msm update --noinput
}

# Updates rest of MSM using init script updater
function setup_jargroup() {
    install_log "Setup default jar groups"
    sudo /usr/bin/msm jargroup create minecraft minecraft
}

function install_complete() {
    install_log "Done. Type 'msm help' to get started. Have fun!"
}

function install_msm() {
    download_latest_files
    update_msm
    setup_jargroup
    install_complete
}

install_msm
mkdir -p /opt/msm/dynmap
chown minecraft:minecraft -R /opt/msm
chown minecraft:apache -R /opt/msm/dynmap
