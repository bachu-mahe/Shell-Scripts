#!/bin/bash
#Script to name a directory based on the existing file names
#move the corresponding file to that directory

set -o errexit -o nounset
#change *.gz part as per the file name requirements
for file in *.gz
do
	dir="${file%.fastq.gz}"
    echo $dir
    mkdir -- "$dir"
    mv -- "$file" "$dir"
done


tophat --output-dir tophat_output_CC1429_1_S1_L004 -p 24 -G /fdb/igenomes/Mus_musculus/UCSC/mm9/Annotation/Genes/genes.gtf --no-novel-juncs --b2-sensitive /fdb/igenomes/Mus_musculus/UCSC/mm9/Sequence/Bowtie2Index/genome CC1429_1_S1_L004_R1.fastq.gz CC1429_1_S1_L004_R2.fastq.gz; mv tophat_output_CC1429_1_S1_L004/accepted_hits.bam tophat_output_CC1429_1_S1_L004/CC1429_1_S1_L004_accepted_hits.bam



#! /bin/bash
> tophat_jobs
# Process PE reads _R1/_R2
ls *_R1.fastq.gz | while read x
do
exp_name="${x:0:${#x}-12}"
echo "tophat --output-dir Ensembl_tophat_output_${exp_name} -p 24 -G /fdb/igenomes/Mus_musculus/UCSC/mm9/Annotation/Genes/genes.gtf --no-novel-juncs --b2-sensitive /fdb/igenomes/Mus_musculus/UCSC/mm9/Sequence/Bowtie2Index/genome ${exp_name}_R1.fastq.gz ${exp_name}_R2.fastq.gz; mv Ensembl_tophat_output_${exp_name}/accepted_hits.bam Ensembl_tophat_output_${exp_name}/${exp_name}_accepted_hits.bam" >> tophat_jobs

done

# Run swarm
swarm -f tophat_jobs -g 20 -t 24 --module tophat


for i in *.gz; do j=`echo $i | sed s/\.fastq.gz//`; echo -ne "Unpacking ${j}.fastq.gz -> ${j}... "; gunzip -c "${j}.fastq.gz" > "${j}.fastq"; echo "done"; echo "Unpacking done. Combining finels now... "; done




samtools sort -n ./Ensembl_tophat_output_RO1/accepted_hits.bam ../Name_Sorted_BAMs/RO1.bam
samtools sort -n ./Ensembl_tophat_output_RO10/accepted_hits.bam ../Name_Sorted_BAMs/RO10.bam
samtools sort -n ./Ensembl_tophat_output_RO11/accepted_hits.bam ../Name_Sorted_BAMs/R11.bam
samtools sort -n ./Ensembl_tophat_output_RO12/accepted_hits.bam ../Name_Sorted_BAMs/RO12.bam
samtools sort -n ./Ensembl_tophat_output_RO13/accepted_hits.bam ../Name_Sorted_BAMs/RO13.bam
samtools sort -n ./Ensembl_tophat_output_RO15/accepted_hits.bam ../Name_Sorted_BAMs/RO15.bam
samtools sort -n ./Ensembl_tophat_output_RO16/accepted_hits.bam ../Name_Sorted_BAMs/RO16.bam
samtools sort -n ./Ensembl_tophat_output_RO2/accepted_hits.bam ../Name_Sorted_BAMs/RO2.bam
samtools sort -n ./Ensembl_tophat_output_RO3/accepted_hits.bam ../Name_Sorted_BAMs/RO3.bam
samtools sort -n ./Ensembl_tophat_output_RO4/accepted_hits.bam ../Name_Sorted_BAMs/RO4.bam
samtools sort -n ./Ensembl_tophat_output_RO5/accepted_hits.bam ../Name_Sorted_BAMs/RO5.bam
samtools sort -n ./Ensembl_tophat_output_RO6/accepted_hits.bam ../Name_Sorted_BAMs/RO6.bam
samtools sort -n ./Ensembl_tophat_output_RO7/accepted_hits.bam ../Name_Sorted_BAMs/RO7.bam
samtools sort -n ./Ensembl_tophat_output_RO8/accepted_hits.bam ../Name_Sorted_BAMs/RO8.bam
samtools sort -n ./Ensembl_tophat_output_RO9/accepted_hits.bam ../Name_Sorted_BAMs/RO9.bam