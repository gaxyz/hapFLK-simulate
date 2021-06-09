#!/usr/bin/env python3
  
import argparse
import pandas as pd

parser = argparse.ArgumentParser( description = "Modify Treemix modelcov matrix for hapFLK input." )
parser.add_argument("infile", type = str, help = "Treemix modelcov matrix")
parser.add_argument("outfile", type=str, help = "Output modelcov hapFLK compatible matrix (gzip compressed).")
parser.add_argument("--outgroup", type=str, help= "Outgroup name to remove", default = "p1")
args = parser.parse_args()

infile = args.infile
outfile = args.outfile
outgroup = args.outgroup

# read matrix
m = pd.read_csv(infile, sep = " ",skiprows=1, header = None)
# get population names column
cols = ["pop"]
cols.extend(list(m[0]))
m.columns = cols 
# modify df
m = m.set_index(m["pop"])
m = m.drop("pop", axis = 1 )
# drop outgroup
m = m.drop(outgroup,axis = 0).drop(outgroup, axis = 1 )
# write
m.to_csv(outfile,sep = " ", header = False, index = True,index_label = False)






