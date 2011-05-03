#!/bin/bash

# TODO: license & stuff

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
JAVA_COVERAGE_DATAFILE=$( "$COVERAGE_CONFIG_SCRIPT" "java.datafile.path" )
PYTHON_COVERAGE_DATAFILE=$( "$COVERAGE_CONFIG_SCRIPT" "python.datafile.path" )
SERVICE_TOMCAT=$( "$COVERAGE_CONFIG_SCRIPT" "service.tomcat6" )

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Parse options
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

javaOutputDir=""
pythonOutputDir=""
javaSrcDir="."
printHelp="false"
set -- $(getopt hj:p:s: "$@")
while [ $# -gt 0 ]
do
    case "$1" in
    (-j) javaOutputDir="$2"; shift;;
    (-p) pythonOutputDir="$2"; shift;;
    (-s) javaSrcDir="$2"; shift;;
    (-h) printHelp="true"; shift;;
    (--) shift; break;;
    (-*) echo "report.sh: error - unrecognized option $1" 1>&2; exit 1;;
    (*)  break;;
    esac
    shift
done

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Usage info
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if $printHelp || [ \( -z "$javaOutputDir" \) -a \( -z "$pythonOutputDir" \) ]; then
    echo "Script generating the HTML coverage reports."
    echo "At least one option -j or -p must be specified."
    echo
    echo "Usage:"
    echo "  ./report.sh [-j java-output-dir] [-p python-output-dir]"
    echo "              [-s java-source-dir] [-h]"
    echo
    echo "Options:"
    echo "  -j java-output-dir  Generates the HTML coverage report of Java" 
    echo "                      source code into directory java-output-dir."
    echo "  -p python-output-dir  Generates the HTML coverage report of Python"
    echo "                        source code into directory python-output-dir"
    echo "  -s java-source-dir  Specifies the path to the root of Java source"
    echo "                      files. Something like java/code/src in"
    echo "                      Spacewalk repository. If not specified, HTML"
    echo "                      report is generated without highlighted source"
    echo "                      code and contains just statistics."
    echo "  -h  Prints this help"
    exit 0
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate HTML report of Java coverage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ ! -z "$javaOutputDir" ]; then
    # restart tomcat
    $SERVICE_TOMCAT restart > /dev/null

    output=$( ant -f $COVERAGE_SCRIPTS_DIR/report_java.xml \
             "-Djava.datafile.path=$JAVA_COVERAGE_DATAFILE" \
             "-Djava.output.dir=$( readlink -f $javaOutputDir )" \
             "-Djava.src.dir=$( readlink -f $javaSrcDir )" html )
    if [ $? -eq 0 ]; then
        echo "report.sh: Java HTML report generated into $javaOutputDir"
    else
        echo "report.sh: Problem with generating of Java HTML report"
        echo "$output"
        exit 1
    fi
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate HTML report of Python coverage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ ! -z "$pythonOutputDir" ]; then
    output=$( $COVERAGE_SCRIPTS_DIR/report_python.py \
              -h $( readlink -f $pythonOutputDir ) \
              "$PYTHON_COVERAGE_DATAFILE" )
    
    if [ $? -eq 0 ]; then
        echo "report.sh: Python HTML report generated into $pythonOutputDir"
    else
        echo "report.sh: Problem with generating of Python HTML report"
        echo "$output"
        exit 1
    fi
fi

exit 0
