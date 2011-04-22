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

COVERAGE_DIR=$( dirname $0 )
COVERAGE_SCRIPTS_DIR=$COVERAGE_DIR/scripts
COVERAGE_VAR_DIR=$( ./$COVERAGE_SCRIPTS_DIR/get_coverage_var_dir.py )
JAVA_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/java.coverage.datafile
PYTHON_COVERAGE_DATAFILE=$COVERAGE_VAR_DIR/python.coverage.datafile
TESTS_DIR=$COVERAGE_DIR/../tests

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Parse options
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

verbose=false
set -- $(getopt v "$@")
while [ $# -gt 0 ]
do
    case "$1" in
    (-v) verbose=true;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*)  break;;
    esac
    shift
done

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#
# Fetches the branch coverage from xml report file specified by given path.
# The branch coverage is number in range 0..100 inclusive.
#
function fetchBranchCoverage {
    branchCoverage=$( "$COVERAGE_SCRIPTS_DIR/fetch_branch_coverage.py" "$1" )

    return $branchCoverage
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tests setup
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if $verbose; then
    echo "### Removing previous data files"
fi

# Clean the coverage data files
rm -f "$JAVA_COVERAGE_DATAFILE" "$PYTHON_COVERAGE_DATAFILE"

# TODO: check whether empty data files exist and print pretty message in case of miss

if $verbose; then
    echo "### Copying the empty Java data file to its place"
fi

# Copy the empty Java data file and set write permissions
\cp $COVERAGE_VAR_DIR/java.coverage.empty.datafile "$JAVA_COVERAGE_DATAFILE"
chmod a+rwx "$JAVA_COVERAGE_DATAFILE"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if $verbose; then
    echo "### Running the tests"
fi

./$TESTS_DIR/runtests.sh
exitCode=$?

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tests teardown
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if $verbose; then
    echo "### Restarting the tomcat6 server"
fi

# Restart the tomcat server in order to save coverage data into datafile
/etc/init.d/tomcat6 restart > /dev/null

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Evaluate the Python coverage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -f $PYTHON_COVERAGE_DATAFILE ]; then
    if $verbose; then
        echo "### Generating the XML report of out Python's coverage data file"
    fi

    # Generate the XML report into temporary file and returns the tmpfile name
    command="python $COVERAGE_SCRIPTS_DIR/report_xml_python.py $PYTHON_COVERAGE_DATAFILE"

    if $verbose; then
        xmlReportPath=$( $command )
    else
        xmlReportPath=$( $command 2> /dev/null )
    fi

    if [ $? -ne 0 ]; then
        if $verbose; then
            echo "$xmlReportPath"
        fi

        echo "Problem with generating of the Python's XML report"
        exit 1
    fi

    fetchBranchCoverage "$xmlReportPath"
    pythonCoverage=$?

    # Remove the temporary file
    rm -f "$xmlReportPath"
else
    if $verbose; then
        echo "### Python coverage data file not found -> zero coverage"
    fi

    pythonCoverage=0
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Evaluate the Java coverage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -f $JAVA_COVERAGE_DATAFILE ]; then
    # Generates the XML report into /tmp/coverage.xml
    command="ant -f $COVERAGE_SCRIPTS_DIR/report_xml_java.xml \
             -Djava.datafile.path=$JAVA_COVERAGE_DATAFILE"

    if $verbose; then
        $command
    else
        $command 2> /dev/null >&2
    fi

    if [ $? -ne 0 ]; then
        echo "Problem with generating of the Java's XML report"
        exit 1
    fi

    xmlReportPath="/tmp/coverage.xml"

    fetchBranchCoverage "$xmlReportPath"
    javaCoverage=$?

    # Remove the temporary file
    rm -f "$xmlReportPath"
else
    javaCoverage=0
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output results
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "Branch coverage: Java $javaCoverage%, Python $pythonCoverage%"
exit $exitCode
