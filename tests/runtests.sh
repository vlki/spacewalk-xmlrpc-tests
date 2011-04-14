#!/bin/bash

TESTS_MODULE_DIR=$( dirname $0 )
BEAKERLIB_TESTS_DIR="$TESTS_MODULE_DIR/RHNSatellite"
ANALYZE_SCRIPT="$TESTS_MODULE_DIR/analyze_beakerlib_journal.py"

stdoutTempFile=$( mktemp )

all=0
pass=0

for makefilePath in $( find $BEAKERLIB_TESTS_DIR -type f -name Makefile )
do
  testDirPath=$( dirname $makefilePath )
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

echo "Passed $pass out of $all tests"

if [ $pass -eq $all ]; then
  exit 0
else
  exit 1
fi
