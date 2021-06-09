#!/usr/bin/env python3
import argparse
from pathlib import Path

parser = argparse.ArgumentParser( description = 'Aggregate hapFLK results in a directory. Aggregation is according to filename.')
parser.add_argument("directory", type=str, help="Directory that contains hapflk files")
parser.add_argument("outfile", type=str, help="Output filename")

args = parser.parse_args()

files = Path(args.directory).glob("*.hapflk") 

outfile = args.outfile

with open(outfile, 'w') as out_handle:
    header = "rs chr pos hapflk K covariance replicate\n"
    out_handle.write(header)

    for f in files:
        filename = str(f)
        covariance, replicate = filename.split("_")
        replicate = replicate.split(".")[0]
        with open(filename, 'r') as in_handle:
            next(in_handle)
            for line in in_handle:
                row = line.rstrip().split()
                row.append(covariance)
                row.append(replicate)
                newline = " ".join(row) + "\n"
                out_handle.write(newline)
