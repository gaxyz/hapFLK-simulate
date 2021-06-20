process SIMULATE{                                                                
    errorStrategy "retry" 
    cpus 1          
    scratch true
    input:                                                                      
        file(slim_script)                                                       
        tuple val(rep_id), val(s), val(m)                                                             
    output:                                                                     
        tuple val(rep_id), val(s), val(m) , file("*.vcf.gz")                         

                                                                                
    """                                                                         
    slim -d s=${s} \
        -d m=${m} \
        -d condfreq=${params.conditioned_frequency} \
        -d rep_id=${rep_id} \
        -d N=${params.N} \
        ${slim_script}
    overlay.py final.trees genotypes_${rep_id}_noids.vcf.gz ${params.sample_size} 
    bcftools annotate --set-id +'%CHROM\\_%POS' genotypes_${rep_id}_noids.vcf.gz >  genotypes_${rep_id}.vcf.gz           
    """                                                                         
                                                                                
}                                                                               
                                                                                
                     
