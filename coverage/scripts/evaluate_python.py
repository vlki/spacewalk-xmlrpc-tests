#!/usr/bin/env python
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#

#
# Script evaluating the coverage.py data file for the coverage of code.
# 
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import coverage
import tempfile
import re
import os
from xml.dom import minidom

def main(argv):
    if len(argv) != 1:
        usage()
        sys.exit(1)

    # Load the coverage.py data file
    cov = coverage.coverage(data_file=argv[0])
    cov.load()

    # Generate the report into temporary file
    reportFileDescriptor, reportFilePath = tempfile.mkstemp()
    reportFile = os.fdopen(reportFileDescriptor, "w")
    cov.report(file=reportFile)
    reportFile.close()
    
    # Get the coverage value
    reportFile = open(reportFilePath, "r")
    for line in reportFile:
       match = re.search("TOTAL.*(\d+)%", line)
       if match:
            print(match.group(1))
    
    # Remove the temporary file
    os.remove(reportFilePath)

def usage():
    pass

if __name__ == "__main__":
    main(sys.argv[1:])
