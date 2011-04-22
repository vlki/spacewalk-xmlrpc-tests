#!/usr/bin/env python

import sys
from lxml import etree

def main(scriptName, argv):
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
    pass

if __name__ == "__main__":
    main("fetch_branch_coverage.py", sys.argv[1:])
