#!/usr/bin/env python3

import argparse
import pandas as pd

parser = argparse.ArgumentParser( description = "Convert frequency table from plink to a count table that works as input for Treemix." )
parser.add_argument("infile", type = str, help = "Input frequency table (plink).")
parser.add_argument("outfile", type=str, help = "Output filename (gzip compressed).")

args = parser.parse_args()

infile = args.infile
outfile = args.outfile


tbl = pd.read_csv(infile, sep = "\s+" , header = 0)







tbl["TMIX"] = tbl["MAC"].astype(str) + "," + (tbl["NCHROBS"] - tbl["MAC"]).astype(str)

tbl["ORDER"] = tbl.index

orderDF = tbl[["SNP","ORDER"]]

tbl = tbl.pivot(columns="CLST", values = "TMIX", index = "SNP")

tbl = orderDF.join(tbl,on="SNP" )

tbl = tbl.drop('ORDER', axis =  1).drop_duplicates().drop('SNP', axis = 1 )



tbl.to_csv(outfile, sep =  " " , index = False, compression="gzip")


