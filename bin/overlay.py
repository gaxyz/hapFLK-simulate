#!/usr/bin/env python3
import argparse
import msprime, pyslim, gzip
import numpy as np
parser = argparse.ArgumentParser( description = 'Overlay neutral mutations into treeseq file and output VCF of last generation.')
parser.add_argument("treeseq", type=str, help="trees file to overlay and write")
parser.add_argument("output", type=str, help="output gzipped VCF file")
parser.add_argument("sample_size", type=int, help="VCF sample size per population")
args = parser.parse_args()


ts = pyslim.load(args.treeseq)
ts = msprime.mutate(ts, rate=1e-7, random_seed=1, keep=True)
ts.dump("overlaid.trees")
ts = pyslim.load("overlaid.trees")
pops = np.unique(ts.individual_populations)
individuals = np.array(0)
populations = np.array(0)
for i in pops:
    inds_sample = np.random.choice(ts.individuals_alive_at(0,population=i),args.sample_size,replace=False)
    pop_ids = np.full(len(inds_sample),i)
    # append
    populations = np.insert(populations,1,pop_ids)
    individuals = np.insert(individuals,1,inds_sample)

individuals = np.delete(individuals,0)
populations = np.delete(populations,0)

ind_names = []

for ind,pop in zip(individuals,populations): 
    name = "p" + str(pop) + ":" + "i" + str(ind)
    ind_names.extend([name])


with gzip.open(args.output, "wt") as f:
    ts.write_vcf(f,individuals=individuals,individual_names=ind_names)


