#!/usr/bin/env nextflow                                                         
nextflow.preview.dsl=2                                                          
workflow {                                                                      

//// SIMULATION                   
include {SIMULATE} from "../modules/simulation"
include {PREPROCESS; COLLECT_FREQUENCIES} from "../modules/wrangling"
//// HAPFLK 
include {KINSHIP_HAPFLK; EMPIRICAL_HAPFLK; THEORETICAL_HAPFLK; TREEMIX_HAPFLK; TREEMIX} from "../modules/analysis"
include {TREEMIX_INPUT; MAF_FILTER; AGGREGATE } from "../modules/wrangling" 

/// Read config file parameters                                           
/////// SIMULATION PARAMETERS ////////      
replicates = params.replicates              /// how many simulation replicates  
scenario = params.scenario                  /// String for scenario name for data processing purposes
scoef=params.scoef                          /// Selection coefficient
mprop=params.mprop                          /// Admixture proportion
conditioned_frequency=params.conditioned_frequency                       /// Conditioned m2 frquency
N=params.N                                  /// Individual population size Ne=2*N
sample_size=params.sample_size              /// Final sampling size (per population)
slim_script = file(params.slim_script)      /// Slim script for simulation

//////// HAPFLK PARAMETERS ////////////
K=params.K                                  /// K for fasPHASE                  
reynold_snps=params.reynold_snps            /// Snps for tree estimation        
nfit=params.nfit                            /// Number of fits to average from (hapFLK)
edges=params.edges                           /// Number of migration edges for computing with treemix
bootstrap=params.bootstrap                  /// bootstrap snp window size for treemix
                        
//// OUTPUT ////
outdir = params.outdir                      /// Output directory name           
////////////////

//////////////////////////////////                                              
//////// Begin pipeline //////////                                              
//////////////////////////////////                                              
                                                                                
                                                                                
// Generate replicate channels                                                        
rep_id = Channel.from(1..replicates)
// Merge with other parameters
s = Channel.fromList( params.scoef )
m = Channel.fromList( params.mprop )

pars = rep_id.combine(s).combine(m)


// SIMULATION-------------------                                                                               
SIMULATE( slim_script, pars  )                                                
vcf = SIMULATE.out[0]                                                         
freqfile = SIMULATE.out[1]

// PREPROCESS

PREPROCESS( vcf ) 
parameter_data = PREPROCESS.out[1]

// COLLECT FREQUENCY DATA
//

COLLECT_FREQUENCIES( freqfile.collect() )

/////// END SIMULATION STAGE ////////////
/////// BEGIN HAPFLK STAGE ///////////////

/// MAF filter                                                                  
MAF_FILTER( PREPROCESS.out )                                                            // TREEMIX---------------------------------                                     
/// Prepare treemix input (LD filtering and wrangling)                          
TREEMIX_INPUT( PREPROCESS.out )                                                         TREEMIX( TREEMIX_INPUT.out )                                                    
// HAPFLK COMPUTATION--------------------------------------------               
// Empirical hapFLK                                                             
/// Compute hapFLK using empricial estimation of kinship matrix                 
KINSHIP_HAPFLK(MAF_FILTER.out)                                                  
// Theoretical hapFLK                                                           
/// Compute hapFLK using theoretical covariance matrix                          
THEORETICAL_HAPFLK( MAF_FILTER.out )                                
// Covariance hapFLK                                                            
/// Compute hapFLK using estimated covariance matrix as kinship                 
EMPIRICAL_HAPFLK( MAF_FILTER.out )                                              
// Treemix covariance                                                           
/// Compute hapFLK using treemix estimated covariance matrix                    
treemix_in = MAF_FILTER.out.join(TREEMIX.out, remainder:true, by: [0,1] )       
TREEMIX_HAPFLK( treemix_in )                                                    
// Aggregate hapflk results                                                     
AGGREGATE( KINSHIP_HAPFLK.out.collect(),                                        
            THEORETICAL_HAPFLK.out.collect(),                                   
            EMPIRICAL_HAPFLK.out.collect(),                                     
            TREEMIX_HAPFLK.out.collect()  )          


}
