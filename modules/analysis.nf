process KINSHIP_HAPFLK{                                                       

    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*.hapflk"
    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*_reynolds.txt"
    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*_tree.txt"
    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*_fij.txt"
    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*_cov.txt"
    scratch true

    publishDir "${params.outdir}/hapflk", pattern: "*"


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
            --reynolds 
    """                                                                         
}                 


process EMPIRICAL_HAPFLK {                                                     

    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*.hapflk"
    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*_reynolds.txt"
    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*_tree.txt"
    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*_fij.txt"


    publishDir "${params.outdir}/hapflk", pattern: "*"


    cpus 5                               
    scratch true                                                                
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
            --reynolds 
    """                                                                         
                                                                                
                                                                                
}       


process TREEMIX_HAPFLK {                                                        

    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*.hapflk"

    publishDir "${params.outdir}/hapflk", pattern: "*"

    
    scratch true
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

    publishDir "${params.outdir}/hapflk/${params.scenario}-${m}-${s}", pattern: "*.hapflk"
    scratch true

                                                                            
    publishDir "${params.outdir}/hapflk", pattern: "*"

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
            --kinship covariance.tab                                             
    """                                                                         
                                                                                
}       
              


process TREEMIX {                                                               
                                                                             
    publishDir "${params.outdir}/treemix/${params.scenario}-s${s}-m${m}", pattern: "*"
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
        
