#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# This script first cleans all the coverage data collected to start with zero
# coverage. The tomcat server is restarted because of Cobertura's data which
# need to be flushed.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

if [[ $(/usr/bin/id -u ) -ne 0 ]]; then
    echo "Must be run as root"
    exit
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Constants setting
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

COVERAGE_DIR=$( readlink -f $( dirname $0 ) )
COVERAGE_SCRIPTS_DIR=$COVERAGE_DIR/scripts
COVERAGE_CONFIG_SCRIPT="$COVERAGE_SCRIPTS_DIR/get_coverage_config_value.py"
COVERAGE_VAR_DIR=$( "$COVERAGE_CONFIG_SCRIPT" "coverage.var.dir" )
JAVA_COVERAGE_DATAFILE=$( "$COVERAGE_CONFIG_SCRIPT" "java.datafile.path" )
PYTHON_COVERAGE_DATAFILE=$( "$COVERAGE_CONFIG_SCRIPT" "python.datafile.path" )
JAVA_COVERAGE_EMPTY_DATAFILE=$( "$COVERAGE_CONFIG_SCRIPT" \
                                "java.emptydatafile.path" )
SERVICE_TOMCAT=$( "$COVERAGE_CONFIG_SCRIPT" "service.tomcat6" )

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tomcat restart
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Restart the tomcat server in order to flush Cobertura's data into data file
$SERVICE_TOMCAT restart > /dev/null

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Do the reset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Clean the coverage data files
rm -f "$JAVA_COVERAGE_DATAFILE" "$PYTHON_COVERAGE_DATAFILE"

if [ ! -f "$JAVA_COVERAGE_EMPTY_DATAFILE" ]; then
    echo -n "The empty Java coverage datafile was not found in path "
    echo "\"$JAVA_COVERAGE_EMPTY_DATAFILE\""
    exit 1
fi

# Copy the empty Java data file and set write permissions
\cp "$JAVA_COVERAGE_EMPTY_DATAFILE" "$JAVA_COVERAGE_DATAFILE"
chmod a+rwx "$JAVA_COVERAGE_DATAFILE"

echo "Coverage data file were successfully reset"
exit 0
