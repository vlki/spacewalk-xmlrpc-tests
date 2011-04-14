#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#

#
# The script used for rollback of the changes made during the installation.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#
#

if [[ $( /usr/bin/id -u ) -ne 0 ]]; then
    echo "Must be run as root"
    exit
fi 

ant -f $( dirname $0 )/build.xml uninstall
