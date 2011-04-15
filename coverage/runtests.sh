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

COVERAGE_DIR=$( dirname $0 )
COVERAGE_SCRIPTS_DIR=$COVERAGE_DIR/scripts
COVERAGE_VAR_DIR=$COVERAGE_DIR/var

JAVA_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/java.coverage.datafile
PYTHON_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/python.coverage.datafile

TESTS_DIR=$COVERAGE_DIR/../tests

# TODO: check whether data files exist and print pretty message in case of miss

# Cleans the coverage data files
\cp $COVERAGE_VAR_DIR/java.coverage.empty.datafile $JAVA_COVERAGE_DATAFILE
\cp $COVERAGE_VAR_DIR/python.coverage.empty.datafile $PYTHON_COVERAGE_DATAFILE

# Run tests
./$TESTS_DIR/runtests.sh
exitCode=$?

# Evaluate the Python coverage
pythonCoverage=$( ./$COVERAGE_SCRIPTS_DIR/evaluate_python.py "$PYTHON_COVERAGE_DATAFILE" )

echo "Branch coverage: Java 50%, Python $pythonCoverage%"
exit $exitCode
