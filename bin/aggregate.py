#!/usr/bin/env python3
import argparse
import gzip
import glob
from progress.bar import Bar
import os

parser = argparse.ArgumentParser(description='Aggregate hapFLK files and FLK files into two separete files')
parser.add_argument("directory", type=str, help="Directory that contains hapFLK and FLK files")
parser.add_argument("scenario", type=str, help="Scenario for output filename")
args = parser.parse_args()
hapflk_files = glob.glob(args.directory + "/" + "*.hapflk")
flk_files = glob.glob(args.directory + "/" + "*.flk")
scenario = args.scenario.replace("/", "")

# process hapflk files
with gzip.open(scenario+"_hapflk.tab.gz", "wb") as outfile:
    outfile.write("rs chr pos hapflk K covariance replicate m s\n".encode())
    with Bar("Processing hapFLK files", max=len(hapflk_files)) as bar:
        for f in hapflk_files:
            basename = os.path.basename(f)
            name = os.path.splitext(basename)
            covariance, replicate, m, s = name[0].split("_")
            with open(f, 'r') as handle:
                next(handle)
                for line in handle:
                    newline = line.rstrip()+" "+covariance+" "+replicate+m+s+"\n"
                    outfile.write(newline.encode())
            bar.next()
print("Done!\n")


# process flk files
with gzip.open(scenario+"_flk.tab.gz", "wb") as outfile:
    outfile.write("rs chr pos pzero flk pvalue covariance replicate m s\n".encode())
    with Bar("Processing FLK files", max=len(flk_files)) as bar:
        for f in flk_files:
            basename = os.path.basename(f)
            name = os.path.splitext(basename)
            covariance, replicate, m, s = name[0].split("_")
            with open(f, 'r') as handle:
                next(handle)
                for line in handle:
                    newline = line.rstrip() + " " + covariance + " " + replicate + "\n"
                    outfile.write(newline.encode())
            bar.next()


print("Done!")
