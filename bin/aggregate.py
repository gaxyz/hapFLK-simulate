#!/usr/bin/env python3
import argparse
import gzip
import glob
from progress.bar import Bar


parser = argparse.ArgumentParser( description = 'Aggregate mutation frequency files for several populations into long tidy format.')
parser.add_argument("directory", type=str, help="Directory that contains .mut files")
parser.add_argument("scenario", type=str, help="Scenario for output filename")
args = parser.parse_args()
hapflk_files = glob.glob(args.directory + "/" + "*.hapflk")
flk_files = glob.glob(args.directory + "/" + "*.flk")
scenario = args.scenario.replace("/","")

# process hapflk files
with gzip.open(scenario+"_hapflk.tab.gz", "wb") as outfile:
    outfile.write("rs chr pos hapflk K covariance replicate\n".encode())
    with Bar("Processing hapFLK files", max=len(hapflk_files)) as bar:
        for f in hapflk_files:
            filename = f
            basename = filename.split(".")[-2]
            covariance = basename.split("_")[0].replace("/","")
            replicate = basename.split("_")[1]
            with open(f, 'r') as handle:
                next(handle)
                for line in handle:
                    newline = line.rstrip() + " " + covariance + " " + replicate + "\n"
                    outfile.write(newline.encode())
            bar.next()
print("Done!\n")


# process flk files
with gzip.open(scenario+"_flk.tab.gz","wb") as outfile:
    outfile.write("rs chr pos pzero flk pvalue covariance replicate\n".encode())
    with Bar("Processing FLK files", max=len(hapflk_files)) as bar:
        for f in hapflk_files:
            filename = f
            basename = filename.split(".")[-2]
            covariance = basename.split("_")[0].replace("/","")
            replicate = basename.split("_")[1]
            with open(f, 'r') as handle:
                next(handle)
                for line in handle:
                    newline = line.rstrip() + " " + covariance + " " + replicate + "\n"
                    outfile.write(newline.encode())
            bar.next()


print("Done!")
