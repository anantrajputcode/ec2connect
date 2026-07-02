#!/bin/bash
#
# ec2connect.sh
#
# Connects to an EC2 instance over SSH.
# Runs a quick non-interactive connectivity test first, then opens a
# real interactive SSH session if the test succeeds.
#
# Usage:
#   ec2connect <key-file-name> <host>
#
# Example:
#   ec2connect mykey.pem 1.2.3.4
#
# Requirements:
#   - Key file must exist at: ~/.ssh/aws-keys/<key-file-name>
#
# Author:  Anant Rajput
# Updated: 2026-07-02


<<task
It is shell script that helps us in connecting to an EC2 server
task

if [[ $# -ne 2 ]];
then
	echo "Usage: ${0} <key-path> <host>"
	exit 1

fi

KEY_PATH="${HOME}/.ssh/aws-keys/${1}" 
HOST="${2}"

if [[ ! -f "${KEY_PATH}" ]];
then
	echo "no KEY found at <KEY_PATH>=${KEY_PATH}"
	exit 1
fi


if ssh -i "${KEY_PATH}" -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=10 ubuntu@"$HOST" "exit" 2>/dev/null;
then
	echo "Connection successful......"
else
    	 echo "Connection failed. Check your key, IP, or security group settings."
   	 exit 1
fi

ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@"$HOST"
echo "************************************************SESSION ENDED***************************************************************"
