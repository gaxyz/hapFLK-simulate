process PREPROCESS {

    publishDir "${params.outdir}/${params.scenario}-s${s}-m${m}-cond${params.conditioned_frequency}"   , pattern:"genotypes_*"  
    cpus 1
    
                                                                               
    input:                                                                      
        tuple val(rep_id), val(s), val(m), file(vcf)
    output:                                                                     
        tuple val(rep_id), val(s), val(m), file("genotypes_${rep_id}.bed"), file("genotypes_${rep_id}.fam"),file("genotypes_${rep_id}.bim")
        
                                                                                
   
    
    """                                                                          
    plink --vcf genotypes_${rep_id}.vcf.gz --keep-allele-order --id-delim : --make-bed --out genotypes_${rep_id} 
    mv genotypes_${rep_id}.bed geno.bed                                         
    mv genotypes_${rep_id}.fam geno.fam                                         
    mv genotypes_${rep_id}.bim geno.bim                                         
                                                                                
    plink --bfile geno --maf 0.05 --nonfounders --make-bed --out genotypes_${rep_id}    
    """    

}




process AGGREGATE{                                                              
                                                                                
    publishDir "$params.outdir", mode: "move"                                   
                                                                                
                                                                                
    input:                                                                      
        file(kinship)                                                          
        file(theoretical)                                                        
        file(empirical)
        file(treemix)                                                           

                                                                                
    output:                                                                     
        file("*.tab.gz")                                                           
                                                                                
                                                                                
    """                                                                         
    aggregate.py . ${params.scenario}                                              
    """                                                                         
                                                                                
}                                                                               


process TREEMIX_INPUT {                                                         
                                                                                
    
                                                                                
    input:                                                                      
        tuple val(rep_id), val(s), val(m), file(bed), file(bim), file(fam)                                            
    output:                                                                     
        tuple val(rep_id),val(s), val(m), file("*.counts.gz")                                  
                                                                                
                                                                                                                                                                
    """                                                                          
    plink --bfile genotypes_${rep_id} --indep-pairwise 100 50 0.1 -out ld       
    plink --bfile genotypes_${rep_id} --extract ld.prune.in --make-bed --out genotypes_${rep_id}_ldpruned
    plink --bfile genotypes_${rep_id}_ldpruned --freq --family --out genotypes_${rep_id}
    prepare-treemix.py genotypes_${rep_id}.frq.strat genotypes_${rep_id}.counts.gz 
    """                                                                                                                                                     
}      

process MAF_FILTER {                                                            
                                                                                
    cpus 1                                                

                                                                                
    input:                                                                      
        tuple val(rep_id), val(s), val(m),file(bed), file(bim), file(fam)                      
                                                                                
    output:                                                                     
        tuple val(rep_id), val(s), val(m), file("genotypes_${rep_id}.bed"), file("genotypes_${rep_id}.bim"),file("genotypes_${rep_id}.fam")
                                                                                
                                                                                
    """                                                                         
    mv genotypes_${rep_id}.bed geno.bed                                         
    mv genotypes_${rep_id}.fam geno.fam                                         
    mv genotypes_${rep_id}.bim geno.bim                                         
                                                                                
    plink --bfile geno --maf 0.05 --nonfounders --make-bed --out genotypes_${rep_id}
    """                                                                         
                                                                                
}                                                                               
    
process COLLECT_FREQUENCIES {

    publishDir "${params.outdir}"   , pattern:"frequencies_*.tsv" , mode: "move"
    
    cpus 1

    input:
        file(freqfile)
    output:
        file("frequencies_*.tsv")

    """
    collect-frequencies.py . --out frequencies_${params.scenario}.tsv
    """           
 

}



 
