#!/bin/bash

HOSTNAME=$(hostname)

# Script that creates an User with password in the Linux system.
NUMBER_OF_PARAMETERS="${#}"

# Parsing the USER_NAME and the description
USER_NAME=${1}

shift
COMMENT=${@}


# Make sure the scrpt is executed as root
if [[ "${UID}" -ne 0 ]]
then
	echo "PLease run with sudo or as root."
	exit 1
fi


# Make sure User name and Description are passed
if [[ "${NUMBER_OF_PARAMETERS}" -lt 1 ]]
then
	echo "Usage: ${0} specify both the USER_NAME and the COMMENT..."
	exit 1
fi

# Check for User existance.
CHECK_FOR_EXISTING_USER=$(id ${USER_NAME} -un)

if [[ "${USER_NAME}" = "${CHECK_FOR_EXISTING_USER}" ]]
then
	echo "The user you are trying to create ${CHECK_FOR_EXISTING_USER} already exists in this Linux env."
	exit 1
fi

# Create thre user and make sure it has an HOME directory. PRovide a description in terms of Firstname and Lastname for it.
useradd -c "${COMMENT}" -m "${USER_NAME}"

CHECK_FOR_EXIT_STATUS="${?}"
if [[ ${CHECK_FOR_EXIT_STATUS} -ne 0 ]]
then
        echo "The account with username ${USER_NAME} failed to be created."
        exit 1
fi

# Generate a password and set the it for the user
PASSWORD=$(date +%s%N | sha256sum | head -c16)
echo "${PASSWORD}" | passwd --stdin "${USER_NAME}"

# Check for exit status
if [[ ${CHECK_FOR_EXIT_STATUS} -ne 0 ]]
then
	echo "The account with username ${USER_NAME} and ${PASSWORD} failed to be created."
	exit 1
fi

# Display username, password and the on what system the user has been created.
echo "User: ${USER_NAME}"
echo
echo "Password: ${PASSWORD}"
echo
echo "System: ${HOSTNAME}"
exit 0


