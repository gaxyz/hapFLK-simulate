#!/usr/bin/env nextflow                                                         
nextflow.enable.dsl=2                                                          
workflow {                                                                      

//// SIMULATION                   
include {SIMULATE} from "../modules/simulation"
include {PREPROCESS} from "../modules/wrangling"
//// HAPFLK 
include {KINSHIP_HAPFLK; EMPIRICAL_HAPFLK; THEORETICAL_HAPFLK; TREEMIX_HAPFLK; TREEMIX} from "../modules/analysis"
include {TREEMIX_INPUT; MAF_FILTER; AGGREGATE } from "../modules/wrangling" 

/// Read config file parameters                                           
slim_script = file(params.slim_script)      /// Slim script for simulation
covariance_script = file(params.covariance_script) /// R script for computing covariance matrix
//////////////////////////////////                                              
//////// Begin pipeline //////////                                              
//////////////////////////////////                                                          
// Generate replicate channels                                                  
rep_id = Channel.from(1..params.replicates)
// Merge with other parameters
s = Channel.fromList( params.scoef )
m = Channel.fromList( params.mcoef )
pars = rep_id.combine(s).combine(m)

// SIMULATION-------------------                                                                               
SIMULATE( slim_script, pars  )                                                
vcf = SIMULATE.out[0]                                                         
freqfile = SIMULATE.out[1]

// PREPROCESS

PREPROCESS( vcf ) 
parameter_data = PREPROCESS.out[1]

/////// END SIMULATION STAGE ////////////
/////// BEGIN HAPFLK STAGE ///////////////

/// MAF filter                                                                  
MAF_FILTER( PREPROCESS.out )  
// TREEMIX---------------------------------                                     
/// Prepare treemix input (LD filtering and wrangling)                          
TREEMIX_INPUT( MAF_FILTER.out ) 
TREEMIX( TREEMIX_INPUT.out )                                                    
// HAPFLK COMPUTATION--------------------------------------------               
// Empirical hapFLK                                                             
/// Compute hapFLK using empricial estimation of kinship matrix                 
KINSHIP_HAPFLK(MAF_FILTER.out)                                                  
// Theoretical hapFLK                                                           
/// Compute hapFLK using theoretical covariance matrix                          
THEORETICAL_HAPFLK( MAF_FILTER.out, covariance_script )                                
// Covariance hapFLK                                                            
/// Compute hapFLK using estimated covariance matrix as kinship                 
EMPIRICAL_HAPFLK( MAF_FILTER.out )                                              
// Treemix covariance                                                           
/// Compute hapFLK using treemix estimated covariance matrix                    
treemix_in = MAF_FILTER.out.join(TREEMIX.out, remainder:true, by: [0,1,2] )       
TREEMIX_HAPFLK( treemix_in )                                                    
// Aggregate hapflk results                                                     
AGGREGATE( KINSHIP_HAPFLK.out.collect(),                                        
            THEORETICAL_HAPFLK.out.collect(),                                   
            EMPIRICAL_HAPFLK.out.collect(),                                     
            TREEMIX_HAPFLK.out.collect()  )          


}
