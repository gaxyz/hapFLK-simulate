#!/usr/bin/env python3
import argparse
from pathlib import Path


parser = argparse.ArgumentParser(description="Collect multiple simulation frequencies into single file.")
parser.add_argument("directory", type=str, help="Directory that contains frequency files")
parser.add_argument("--out", type=str, required=True)
args = parser.parse_args()


mutfiles = sorted(Path(args.directory).glob("frequencies_*.mut"))


with open(args.out, 'w') as outfile:
    outfile.write("generation pop freq s m rep\n")

    for i in mutfiles: 
        with open(i, 'r') as freqfile:
            for line in freqfile:

                outfile.write(line)
