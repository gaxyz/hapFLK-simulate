process SIMULATE{                                                                
    scratch true                                                                                
    cpus 1          

    input:                                                                      
        file(slim_script)                                                       
        tuple val(rep_id), val(s), val(m)                                                             
    output:                                                                     
        tuple val(rep_id), val(s), val(m) , file("*.vcf")                         
        file("frequencies_*.mut")    
                                                                                
    """                                                                         
    slim -d s=${s} \
        -d m=${m} \
        -d condfreq=${params.conditioned_frequency} \
        -d rep_id=${rep_id} \
        -d N=${params.N} \
        -d sample_size=${params.sample_size} \
        ${slim_script}
    
    aggregate-frequencies.py . frequencies_${rep_id}_s${s}_m${m}.mut \
                                --rep_id ${rep_id} \
                                --m ${m} \
                                --s ${s}
         
    """                                                                         
                                                                                
}                                                                               
                                                                                
                     
