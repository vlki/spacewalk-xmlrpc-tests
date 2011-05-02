#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#

#
# The script used for running all the BeakerLib tests which reside
# in the RHNSatellite directory and evaluating the success.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

TESTS_MODULE_DIR=$( dirname $0 )
BEAKERLIB_TESTS_DIR="$TESTS_MODULE_DIR/RHNSatellite"
ANALYZE_SCRIPT="$TESTS_MODULE_DIR/analyze_beakerlib_journal.py"

# if first parameter is specified, use it as tests directory
if [ -n "$1" ]; then
  BEAKERLIB_TESTS_DIR="$1"
fi

stdoutTempFile=$( mktemp )

all=0
pass=0

for makefilePath in $( find $BEAKERLIB_TESTS_DIR -type f -name Makefile )
do
  testDirPath=$( dirname $makefilePath )

  # Execute that make only if there are files PURPOSE and runtest.sh
  if [ ! \( -f "$testDirPath/PURPOSE" -a -f "$testDirPath/runtest.sh" \) ]
  then
    continue
  fi

  make -C "$testDirPath" > "$stdoutTempFile"
 
  # Parse the path to a XML journal from the output
  testJournalXml=$( grep ":: JOURNAL XML" "$stdoutTempFile" | sed -r "s/^.*JOURNAL XML: (.*)$/\1/" | uniq )

  # Resolve the overall result. Variable testResult is set either to "PASS" or to "FAIL".
  testResult=$( $ANALYZE_SCRIPT "$testJournalXml" )

  # Mark, that we run the test
  all=$( expr $all + 1 )

  if [ "$testResult" == "PASS" ]; then
    # If it run successfully, just mark it as passed
    pass=$( expr $pass + 1 )
  else
    # In case of failure, print the test name and path to the TXT journal for further investigation
    testName=$( $ANALYZE_SCRIPT -t "$testJournalXml" )
    testJournalTxt=$( grep ":: JOURNAL TXT" "$stdoutTempFile" | sed -r "s/^.*JOURNAL TXT: (.*)$/\1/" | uniq )
    echo "FAIL of $testName: See $testJournalTxt"
  fi
done

# Remove the temporary file used for test outputs
rm -f "$stdoutTempFile"

if [ $all -eq 0 ]; then
  echo "No tests found in $BEAKERLIB_TESTS_DIR"
else
  echo "Passed $pass out of $all tests"
fi

if [ $pass -eq $all ]; then
  exit 0
else
  exit 1
fi
