#!/usr/bin/env python3
import argparse
import msprime, pyslim, gzip
import numpy as np
import random 

parser = argparse.ArgumentParser( description = 'Overlay neutral mutations into treeseq file and output VCF of last generation.')
parser.add_argument("treeseq", type=str, help="trees file to overlay and write")
parser.add_argument("output", type=str, help="output gzipped VCF file")
parser.add_argument("sample_size", type=int, help="VCF sample size per population")
args = parser.parse_args()

def make_alleles(n):
    nucs = ['A', 'C', 'G', 'T']
    alleles = nucs.copy()
    random.shuffle(alleles)
    while len(alleles) < n:
        new = [a + b for a in alleles for b in nucs]
        random.shuffle(new)
        alleles.extend(new)
    return alleles[:n]

ts = pyslim.load(args.treeseq)
ts = msprime.mutate(ts, rate=1e-8, random_seed=1, keep=True)
ts.dump("overlaid.trees")
ts = pyslim.load("overlaid.trees")
t = ts.tables
t.sites.clear()
t.mutations.clear()

for s in ts.sites():
    alleles = make_alleles(len(s.mutations) + 1)
    t.sites.append(s.replace(ancestral_state=alleles[0]))
    for j, m in enumerate(s.mutations):
        t.mutations.append(m.replace(derived_state=alleles[j+1]))


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

ts=t.tree_sequence()
with gzip.open(args.output, "wt") as f:
    ts.write_vcf(f,individuals=individuals,individual_names=ind_names, position_transform="legacy")


