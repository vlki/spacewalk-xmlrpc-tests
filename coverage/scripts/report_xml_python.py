#!/usr/bin/env python
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#

#
# Script evaluating the coverage.py data file and generating the XML
# report into temporary file. The path to that temporary file is 
# then printed.
# 
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import coverage
import tempfile
import os

def main(scriptName, argv):
    """
    The main script function.
    """
    if len(argv) != 1:
        usage()
        sys.exit(1)

    if not os.path.exists(argv[0]):
        print(scriptName + ": Given data file does not exist.")
        exit(1)

    # Load the coverage.py data file
    cov = coverage.coverage(data_file=argv[0])
    cov.load()

    # Generate the report into temporary file
    reportFileDescriptor, reportFilePath = tempfile.mkstemp()
    try:
        cov.xml_report(outfile=reportFilePath)
    except coverage.misc.CoverageException as e:
        print(scriptName + ": Cannot generate report. Given data file is probably broken.")
        exit(1)

    # Return the path to the temporary file
    print(reportFilePath)
    exit(0)    

def usage():
    """
    Prints the usage information.
    """
    print("Script evaluating the coverage.py data file and generating the XML")
    print("report into temporary file. The path to that temporary file is")
    print("then printed.")
    print("")
    print("Usage:")
    print(" ./report_xml_python.py coverage-data-file")
    print("")
    pass

if __name__ == "__main__":
    main("report_xml_python.py", sys.argv[1:])
