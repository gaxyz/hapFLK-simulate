process SIMULATE{ 
<<<<<<< HEAD
    publishDir "${params.outdir}/vcf/${params.scenario}-s${s}-m${m}", pattern: "genotypes_${rep_id}.vcf.gz"
                                                               
    errorStrategy "retry"
    scratch true 
    cpus 2          
=======
    publishDir "${params.outdir}/${params.scenario}-s${s}-m${m}/genotypes", pattern: "genotypes_${rep_id}.vcf.gz"
                                                               
    errorStrategy "retry"
     
    cpus 1          
>>>>>>> efeb7c9f85efff0ed5ae882a07e807b7cfb5a414
   
    input:                                                                      
        file(slim_script)                                                       
        tuple val(rep_id), val(s), val(m)                                                             
    output:                                                                     
        tuple val(rep_id), val(s), val(m) , file("genotypes_${rep_id}.vcf.gz")                         

                                                                                
    """                                                                         
    slim -d s=${s} \
        -d m=${m} \
        -d condfreq=${params.conditioned_frequency} \
	-d onsetFreq=${params.onsetFreq} \
	-d epsilon=${params.epsilon} \
        -d rep_id=${rep_id} \
        -d N=${params.N} \
        ${slim_script}
    overlay.py final.trees genotypes_${rep_id}_noids.vcf.gz ${params.sample_size} 
    bcftools annotate --set-id +'chr%CHROM-%POS' genotypes_${rep_id}_noids.vcf.gz  > genotypes_${rep_id}.vcf.gz           
    """                                                                         
                                                                                
}                                                                               
                                                                                
                     
