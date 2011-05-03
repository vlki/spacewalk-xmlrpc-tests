#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# This script extends the running of tests from tests module with
# reseting of coverage data files before and evaluating them after.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

if [[ $(/usr/bin/id -u ) -ne 0 ]]; then
    echo "Must be run as root"
    exit
fi

# Constants
COVERAGE_DIR=$( readlink -f $( dirname $0 ) )
TESTS_DIR=$COVERAGE_DIR/../tests

# Reset the data files
$COVERAGE_DIR/reset.sh

# Wait till Tomcat starts completely
sleep 2m

# Run tests
$TESTS_DIR/runtests.sh
exitCode=$?

# Evaluate the coverage
$COVERAGE_DIR/evaluate.sh

exit $exitCode
