#!/bin/bash

if [[ $( /usr/bin/id -u ) -ne 0 ]]; then
    echo "Must be run as root"
    exit
fi 

ant -f install/build.xml
