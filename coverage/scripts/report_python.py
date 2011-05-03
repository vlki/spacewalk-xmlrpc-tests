#!/usr/bin/env python
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#

#
# Script evaluating the coverage.py data file and generating the XML
# report into temporary file or HTML report into given destination.
# In case of XML, the path to that temporary file is then printed.
# 
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import coverage
import tempfile
import getopt
import os

def main(scriptName, argv):
    """
    The main script function.
    """
    htmlOutputDir = None

    try:
        # there is one optinal parameter "html"
        opts, args = getopt.getopt(argv, "h:", ["html="])
    except getopt.GetoptError:
        usage()
        sys.exit(1)
    for opt, arg in opts:
        if opt in ("-h", "--html"):
            htmlOutputDir = arg

    if len(args) != 1:
        usage()
        sys.exit(1)

    if not os.path.exists(args[0]):
        print(scriptName + ": Given data file does not exist.")
        exit(1)

    # Load the coverage.py data file
    cov = coverage.coverage(data_file=args[0])
    cov.load()

    if htmlOutputDir is None:
        # Generate the report into temporary file
        reportFileDescriptor, reportFilePath = tempfile.mkstemp()
        try:
            cov.xml_report(outfile=reportFilePath)
        except coverage.misc.CoverageException as e:
            print(scriptName + ": Cannot generate XML report. \
Given data file is probably broken.")
            exit(1)

        # Return the path to the temporary file
        print(reportFilePath)
    else:
        try:
            cov.html_report(directory=htmlOutputDir)
        except IOError as e:
            print(scriptName + ": Cannot generate HTML report. \
Given output directory is probably not writable.")
            exit(1)
        except coverage.misc.CoverageException as e:
            print(scriptName + ": Cannot generate HTML report. \
Given data file is probably broken.")
            exit(1)
    
    exit(0)    

def usage():
    """
    Prints the usage information.
    """
    print("Script evaluating the coverage.py data file and generating the XML")
    print("report into temporary file or HTML report into given destination.")
    print("In case of XML, the path to that temporary file is then printed.")
    print("")
    print("Usage:")
    print(" ./report_xml_python.py [-h dir|--html dir] coverage-data-file")
    print("")
    print("Options:")
    print(" -h|--html dir   If set, HTML report will be generated instead of")
    print("                 the XML one. Given dir is the output directory.")
    pass

if __name__ == "__main__":
    main("report_python.py", sys.argv[1:])
