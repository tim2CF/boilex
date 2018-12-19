#!/bin/bash

set -e
set -x

arguments=( "$@" )
variables=( "${arguments[@]:1}" )
message="${arguments[0]}"

for varname in "${variables[@]}"
do
  if [[ -z "${!varname}" ]]; then
      echo "please set variable $varname $message"
      exit 1
  fi
done
