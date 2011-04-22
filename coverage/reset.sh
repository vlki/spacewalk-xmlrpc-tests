#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# This script first cleans all the coverage data collected to start with zero
# coverage. Then it runs all tests and evaluates the coverage from collected
# data.
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
COVERAGE_VAR_DIR=$( $COVERAGE_SCRIPTS_DIR/get_coverage_var_dir.py )
JAVA_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/java.coverage.datafile
PYTHON_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/python.coverage.datafile

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Do the reset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Clean the coverage data files
rm -f "$JAVA_COVERAGE_DATAFILE" "$PYTHON_COVERAGE_DATAFILE"

# TODO: check whether empty data files exist and print pretty message in case of miss

# Copy the empty Java data file and set write permissions
\cp $COVERAGE_VAR_DIR/java.coverage.empty.datafile "$JAVA_COVERAGE_DATAFILE"
chmod a+rwx "$JAVA_COVERAGE_DATAFILE"

echo "Coverage data file were successfully reset"
