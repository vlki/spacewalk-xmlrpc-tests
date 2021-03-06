#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# This scripts restarts the tomcat server in order to force Cobertura to
# flush coverage data into file and then evaluates the both coverage data
# files for branch coverage.
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
SERVICE_TOMCAT=$( "$COVERAGE_CONFIG_SCRIPT" "service.tomcat6" )

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tomcat restart
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Restart the tomcat server in order to save Cobertura's data into data file
$SERVICE_TOMCAT restart > /dev/null

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Evaluate the Python coverage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -f $PYTHON_COVERAGE_DATAFILE ]; then
    # Generate the XML report into temporary file and returns the tmpfile name
    command="$COVERAGE_SCRIPTS_DIR/report_python.py $PYTHON_COVERAGE_DATAFILE"

    xmlReportPath=$( $command )

    if [ $? -ne 0 ]; then
        echo "$xmlReportPath"
        echo "Problem with generating of the Python's XML report"
        exit 1
    fi

    pythonCoverage=$( "$COVERAGE_SCRIPTS_DIR/fetch_branch_coverage.py" "$xmlReportPath" )

    # Remove the temporary file
    rm -f "$xmlReportPath"
else
    pythonCoverage=0
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Evaluate the Java coverage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -f $JAVA_COVERAGE_DATAFILE ]; then
    # Generates the XML report into /tmp/coverage.xml
    command="ant -f $COVERAGE_SCRIPTS_DIR/report_java.xml \
             -Djava.datafile.path=$JAVA_COVERAGE_DATAFILE xml"

    antOutput=$( $command )

    if [ $? -ne 0 ]; then
        echo "$antOutput"
        echo "Problem with generating of the Java's XML report"
        exit 1
    fi

    xmlReportPath="/tmp/coverage.xml"

    javaCoverage=$( "$COVERAGE_SCRIPTS_DIR/fetch_branch_coverage.py" "$xmlReportPath" )

    # Remove the temporary file
    rm -f "$xmlReportPath"
else
    javaCoverage=0
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output results
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "Branch coverage: Java $javaCoverage%, Python $pythonCoverage%"

