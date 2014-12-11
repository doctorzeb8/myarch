#!/bin/bash
if [ ! -z "$1" ]; then
  sed -i -e "/root ALL=(ALL) ALL/a $username ALL=(ALL) PASSWD: ALL, NOPASSWD: $nopasswd" $1
  sed -i -e 's/^# *Defaults targetpw/Defaults targetpw/' $1
else
  export EDITOR=$0
  visudo
fi
