#!/usr/bin/env python3
import argparse
import pandas as pd
from pathlib import Path

parser = argparse.ArgumentParser( description = 'Aggregate mutation frequency files for several populations into long tidy format.')
parser.add_argument("directory", type=str, help="Directory that contains .mut files")
parser.add_argument("outfile", type=str, help="Output filename")
parser.add_argument("--rep_id", type=str, required = True )
parser.add_argument("--m", type=str, required = True )
parser.add_argument("--s", type=str, required = True )

args = parser.parse_args()

mutfiles = sorted( Path(args.directory).glob("p*.mut") )

for i, f in enumerate(mutfiles):
    if i == 0:
        final = pd.read_table(f, sep = " ", index_col = 0)
    else:
        tmp = pd.read_table(f, sep=" ", index_col=0)
        final = tmp.join(final, on="generation", how= "right")

print(final.columns)
final = final.reset_index()
final = final.melt(id_vars=["generation"])
final.columns = ["generation","pop","freq"]
final["s"] = args.s
final["m"] = args.m
final["rep"] = args.rep_id

(final
    .to_csv(args.outfile, sep=" ", index=False, na_rep="NA", header=False))

