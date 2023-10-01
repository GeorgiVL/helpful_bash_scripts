#!/bin/bash

# Force the Help Desk to run the script as root or with sudo.
check_for_sudo_root_run() {
    if [[ "${UID}" -ne 0 ]]; then
        echo "Please run with sudo or as root" >&2
        exit 1
    fi
}

# Provide a usage statement if not enough arguments are supplied.
usage() {
    echo "Usage: ${0} [-d] [-r] [-a] username1 [username2 ...]" >&2
    echo "     -d Deletes the user account."
    echo "     -r Removes the home directory associated with the account(s)."
    echo "     -a Creates an archive of the home directory with the account(s) and stores the archive in the /archive directory."
    exit 1
}

# Refuse to disable/delete any account that is a system account - Help desk can disable users accounts only.
refuse_to_disable_system_accounts() {
    for username in "${USERS[@]}"; do
        USER_ID=$(id -u "${username}")
        if [[ "${USER_ID}" -lt 1000 ]]; then
            echo "Refusing to disable/delete system account: ${username}"
            exit 1
        fi
    done
}

# Check if the /archive directory exists; if not, create it.
check_for_archive() {
    if [[ ! -d "/archive" ]]; then
        echo "The /archive directory doesn't exist."
        echo "Creating the /archive directory..."
        mkdir -p "/archive"
    fi
}

# Check if the specified user exists.
check_user_existence() {
    for username in "${USERS[@]}"; do
        if ! id "${username}" &>/dev/null; then
            echo "User not found: ${username}" >&2
            exit 1
        fi
    done
}

check_for_sudo_root_run
DELETE_USER=false
REMOVE_HOME=false
BACKUP_HOME=false

# Parse command-line options
while getopts :dra OPTION; do
    case ${OPTION} in
        d)
            DELETE_USER=true
            ;;
        r)
            REMOVE_HOME=true
            ;;
        a)
            BACKUP_HOME=true
            ;;
        ?)
            usage
            ;;
    esac
done

# Shift to remove the options, leaving only the usernames
shift "$((OPTIND - 1))"
USERS=("${@}")

# Check if the specified user(s) exist(s)
check_user_existence

# Refuse to disable/delete system accounts
refuse_to_disable_system_accounts

# Lock/disable the user
for username in "${USERS[@]}"; do
        passwd -l "${username}" 1> /dev/null
        if [[ "${?}" -eq 0 ]]; then
                echo "Locked user: ${username}"
        else
                echo "Failed to lock user: ${username}" >&2
        fi
done

# Perform actions based on options
for username in "${USERS[@]}"; do
    if [[ "${DELETE_USER}" = 'true' ]]; then
        userdel "${username}"
        echo "User account '${username}' has been deleted."
    fi

    if [[ "${BACKUP_HOME}" = 'true' ]]; then
        if check_for_archive; then
            tar -czvf "/archive/${username}.tar.gz" "/home/${username}" &> /dev/null
            echo "Home directory for user '${username}' has been backed up to /archive/${username}.tar.gz"
        else
            echo "Failed to archive the /home/${username} directory."
        fi
    fi

    if [[ "${REMOVE_HOME}" = 'true' ]]; then
        rm -rf "/home/${username}"
        echo "Home directory for user '${username}' has been removed."
    fi
done

exit 0

