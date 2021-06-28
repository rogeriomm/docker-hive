#!/bin/bash

set -e

TAG=$(git rev-parse --abbrev-ref HEAD)

build() {
    USER=$1
    PREFIX=$2
    NAME=$3
    if [ "$NAME" = "" ]; then
      IMAGE=$USER/$PREFIX:$TAG
    else
      IMAGE=$USER/$PREFIX-$NAME:$TAG
    fi
    cd $([ -z "$4" ] && echo "./$NAME" || echo "$4")
    echo '--------------------------' building $IMAGE in $(pwd)
    echo "docker build -t $IMAGE --build-arg USERNAME=$1 --build-arg TAG=$TAG ."
    docker build --no-cache -t $IMAGE --build-arg USERNAME=$1 --build-arg TAG=$TAG .
    cd -
}

while getopts u:a:f: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        *);;
    esac
done

if [ "$username" == "" ] ; then
  echo "Invalid user name"
  exit
fi

build "$username" hive