#!/usr/bin/env bash

set -e

if [ $(uname -m) == 'x86_64' ] 
then
	tag=
elif [ $(uname -m) == 'aarch64' ] 
then 
	tag=:arm64
else
	echo 'not matched platform!'
	exit 0
fi

docker build -t wn1980/nvidia-ros${tag} .