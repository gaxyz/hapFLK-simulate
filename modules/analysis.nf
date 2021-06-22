process KINSHIP_HAPFLK{                                                       
    publishDir "${params.outdir}/${params.scenario}"                                                                                
    cpus 5                                                                      
                                                                                
    input:                                                                      
        tuple val(rep_id) ,val(s), val(m), file(bed), file(bim), file(fam)                     
    output:                                                                     
        tuple val(rep_id),val(s), val(m) , file("*.flk"), file("*.hapflk"), file("*_fij.txt")  
                                                                                
    """                                                                         
    hapflk --ncpu ${task.cpus} \
            --reynolds-snps ${params.reynold_snps} \
            --bfile genotypes_${rep_id} \
            --prefix kinship_${rep_id} \
            --outgroup p1 \
            -K ${params.K} \
            --phased     \
            --reynolds \
            --nfit ${params.nfit}                                               
    """                                                                         
}                 


process EMPIRICAL_HAPFLK {                                                     
    publishDir "${params.outdir}/${params.scenario}"

                                                                                
    cpus 5                                                                      
                                                                                
    input:                                                                      
        tuple val(rep_id), val(s), val(m), file(bed), file(bim), file(fam)                     
    output:                                                                     
        tuple val(rep_id),val(s), val(m) , file("*.flk"), file("*.hapflk"), file("*_fij.txt")  
                                                                                
    """                                                                         
    hapflk --ncpu ${task.cpus} \
            --reynolds-snps ${params.reynold_snps} \
            --bfile genotypes_${rep_id} \
            --prefix empirical_${rep_id} \
            --outgroup p1 \
            -K ${params.K} \
            --phased     \
            --covkin \
            --reynolds \
            --nfit ${params.nfit}                                               
    """                                                                         
                                                                                
                                                                                
}       






process TREEMIX_HAPFLK {                                                        
    publishDir "${params.outdir}/${params.scenario}"

                                                                                
    cpus 5                                                                      
                                                                                
    input:                                                                      
        tuple val(rep_id),val(s), val(m), file(bed), file(bim), file(fam), file(covariance)    
                                                                                
    output:                                                                     
        tuple val(rep_id) ,val(s), val(m), file("*.flk"), file("*.hapflk")                     
                                                                                
    """                                                                         
    hapflk --ncpu ${task.cpus} \
            --reynolds-snps ${params.reynold_snps} \
            --bfile genotypes_${rep_id} \
            --prefix treemix_${rep_id} \
            --outgroup p1 \
            -K ${params.K} \
            --phased     \
            --nfit ${params.nfit} \
            --kinship ${covariance}                                             
    """                                                                         
}                                                                              

process THEORETICAL_HAPFLK{                                                     
    publishDir "${params.outdir}/${params.scenario}"                                  
                                                                            
    cpus 5                                                                      
                                                                                
    input:                                                                      
        tuple val(rep_id) ,val(s), val(m), file(bed), file(bim), file(fam) 
        file(covariance_script)
    output:                                                                     
        tuple val(rep_id) ,val(s), val(m), file("*.flk"), file("*.hapflk")                     
                                                                                
    """
    Rscript ${covariance_script} ${params.N} ${m}

                              
    hapflk --ncpu ${task.cpus} \
            --reynolds-snps ${params.reynold_snps} \
            --bfile genotypes_${rep_id} \
            --prefix theoretical_${rep_id} \
            --outgroup p1 \
            -K ${params.K} \
            --phased     \
            --nfit ${params.nfit} \
            --kinship covariance.tab                                             
    """                                                                         
                                                                                
}       
              


process TREEMIX {                                                               
                                                                             
    cpus 1                                                                      
                                                                                
    input:                                                                      
        tuple val(rep_id),val(s), val(m), file(countfile)                                      
                                                                                
    output:                                                                     
        tuple val(rep_id),val(s), val(m), file("*_covariance.tab")                             
                                                                                
                                                                                
                                                                                
    """                                                                         
    treemix -i ${countfile} \
            -m ${params.edges} \
            -o ${rep_id}_${params.edges}  \
            -bootstrap -k ${params.bootstrap}                                   
                                                                                
    prepare-modelcov.py ${rep_id}_${params.edges}.modelcov.gz ${rep_id}_${params.edges}_covariance.tab 
    
   
    """                                                                         
                                                                                
}                                                                               
        
