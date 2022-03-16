#!/bin/bash

# The usage is simply: ssh-add-pass keyfile passfile
if [ $# -ne 2 ] ; then
  echo "Usage: ssh-add-pass keyfile passfile"
  exit 1
fi

eval $(ssh-agent)
pass=$2

expect <(cat << EOF
  spawn ssh-add $1
  expect "Enter passphrase"
  send "$pass\r"
  expect eof
EOF
)