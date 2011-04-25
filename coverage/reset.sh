#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# This script first cleans all the coverage data collected to start with zero
# coverage.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Constants setting
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

COVERAGE_DIR=$( readlink -f $( dirname $0 ) )
COVERAGE_SCRIPTS_DIR=$COVERAGE_DIR/scripts
COVERAGE_VAR_DIR=$( $COVERAGE_SCRIPTS_DIR/get_coverage_var_dir.py )
JAVA_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/java.coverage.datafile
PYTHON_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/python.coverage.datafile
JAVA_COVERAGE_EMPTY_DATAFILE=$COVERAGE_VAR_DIR/java.coverage.empty.datafile

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
