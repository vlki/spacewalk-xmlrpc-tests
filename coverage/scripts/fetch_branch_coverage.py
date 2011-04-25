#!/usr/bin/env python
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#

#
# This script parses the XML coverage report (the Cobertura format) and
# and fetches the branch coverage out of it.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
from lxml import etree

def main(scriptName, argv):
    """
    The main script function.
    """
    if len(argv) != 1:
        usage()
        exit(1)

    # Parse the XML report into lxml tree and get the root
    tree = etree.parse(argv[0])
    root = tree.getroot()

    # Get the branch-rate attribute of root node and convert it to
    # integer percents
    branch_rate = float(root.get("branch-rate"))
    branch_coverage = int(round(branch_rate * 100))
    
    # Output without trailing newline
    sys.stdout.write(str(branch_coverage))
    exit(0)

def usage():
    """
    Prints the usage information.
    """
    print("This script parses the XML coverage report (the Cobertura format)")
    print("and fetches the branch coverage out of it.")
    print("")
    print("Usage:")
    print(" ./fetch_branch_coverage.py xml-report-file")
    print("")
    pass

if __name__ == "__main__":
    main("fetch_branch_coverage.py", sys.argv[1:])
