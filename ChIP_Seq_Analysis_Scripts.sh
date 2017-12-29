#! /bin/bash
set -o pipefail
set -e
echo "Running on $SLURM_CPUS_PER_TASK CPUs"
threads=$(( SLURM_CPUS_PER_TASK - 2 ))
module load bowtie || exit 1
module load samtools || exit 1
#Used for Single End ChIP-Seq Data
for i in *.fastq.gz
do
	j=`echo $i | sed s/\.fastq.gz//`
	echo "cd /data/bachum/Hira-LSK-ChIP \
   && export BOWTIE2_INDEXES=/fdb/igenomes/Mus_musculus/UCSC/mm9/Sequence/Bowtie2Index \
   && bowtie2 --sensitive-local -p \$(( SLURM_CPUS_PER_TASK - 2 )) --no-unal -x genome -U ${j}.fastq.gz | samtools view -q30 -Sb - > ${j}.bam"
done
#############################################################################################################################
#For loop to sort BAM files
#! /bin/bash
set -e
module load samtools
cd /data/bachum/data/Chao_Data/Chao_Merged_FastQ_Files_11182015/Bam_Files
for i in *.bam
do
	j=`echo $i | sed s/\.bam//`
	echo "samtools sort -T /tmp/${j}.bam -o ${j}_sorted.bam ${j}.bam && rm ${j}.bam && samtools rmdup -s ${j}_sorted.bam ${j}_sorted_rmdup.bam && rm ${j}_sorted.bam && samtools index ${j}_sorted_rmdup.bam" >> bam_sort_swarm
done
#############################################################################################################################
for i in *.bam
do
	j=`echo $i | sed s/\.bam//`
	echo "samtools rmdup -s ${j}.bam ${j}_sorted_rmdup.bam" >> bam_rmdup
done
#############################################################################################################################


#For loop to index BAM files
for i in *.bam
do
echo "samtools index $i" >> bam_index
done
#############################################################################################################################
#Fold enrichment in MACS
for i in *.bdg
do
j="${i:0:${#i}-17}"
echo "macs2 bdgcmp -t ${j}_treat_pileup.bdg -c ${j}_control_lambda.bdg -o ${j}_FE.bdg -m FE" >> macs2_fold-enrichment
#scan through the resulting file for naming consistency
done
#############################################################################################################################
#Log-ratio calculation in MACS
for i in *.bdg
do
j="${i:0:${#i}-17}"
echo "macs2 bdgcmp -t ${j}_treat_pileup.bdg -c ${j}_control_lambda.bdg -o ${j}_logLR.bdg -m logLR -p 0.00001" >> macs2_LogRatio
#scan through the resulting file for naming consistency
done
#############################################################################################################################
#Clipping for bigWig Conversion
#! /bin/bash
set -o pipefail
set -e
module load ucsc
module load bedtools
for x in *.bdg
do
j="${x:0:${#x}-4}"
bedtools slop -i ${j}.bdg -g mm9.len -b 0 | bedClip stdin mm9.len ${j}.clip
done
#############################################################################################################################
for x in *.sorted.clipclip
do
	j="${x:0:${#x}-5}"
	echo "LC_COLLATE=C sort -k1,1 -k2,2n ${j}.clip > ${j}.sorted.clip" >> clip_sort
done

#Bedgraph to BigWiggle Conversion
#! /bin/bash
set -o pipefail
set -e
module load ucsc
module load bedtools

for x in *.sorted.clip
do
j="${x:0:${#x}-5}"
echo "bedGraphToBigWig ${j}.clip mm9.Chrom.Sizes ${j}.FE.bw"
done

#############################################################################################################################
#Bedfile conversion
for x in *.bam
do
j="${x:0:${#x}-4}"
echo "bedtools bamtobed -i ${j}.bam > Bed_Files/${j}.bed" >> bedtools_command
done
#############################################################################################################################
#sicer peak calling
#!/bin/bash
module load sicer
cp -r /usr/local/apps/sicer/1.1/ex .
cd /data/bachum/data/Chao_Data/MEF_PolII_k36me3_WtandKO/Bam_Files/Sorted_BAMs/Bed_Files/KO_Data
for x in *.bed
do
j="${x:0:${#x}-4}"
sh $SICERDIR/SICER.sh . ${j}.bed KO_ChIP_051315_Input_sorted.bed Sicer_OutPut mm9 1 200 150 0.77 400 .01
done
#############################################################################################################################
#! /bin/bash
#SBATCH --job-name=bamUtil

set -e
module load bamutil/1.0.13

for x in *.bam
do
j="${x:0:${#x}-4}"
echo "bam stats --in $x --qual --basic > ${j}_Stats.txt" >> bamutils_swarm
done
#############################################################################################################################



for i in *.bam
do
j="${i:0:${#i}-4}"
echo "bamCoverage --bam ${j}.bam --outFileName ${j}.bigWig --outFileFormat bigwig --normalizeTo1x 2150570000 --numberOfProcessors max" >> deeptools_command
done
#############################################################################################################################




for i in *.bam
do
	j=`echo $i | sed s/\.bam//`;
	echo "bamCoverage --bam $i --outFileName $j --outFileFormat bigwig --bamIndex $i.bai --normalizeTo1x 2150570000 --binSize 10" >> bamcoverage_command
done


computeMatrix scale-regions --regionsFileName genes.bed --scoreFileName KOA_06172015_Hira_0h_Wt_R1_sorted.bw --beforeRegionStartLength 3000 --afterRegionStartLength 3000 --regionBodyLength 5000 --binSize 1 --outFileName Hira_0h_matrix --outFileNameData Hira_0h_profile.tab --outFileNameMatrix Hira_0h_IndividualValues.tab --outFileSortedRegions Hira_0h_Heatmap1sortedRegions.bed

#############################################################################################################################
for i in *.bam
do
	j=`echo $i | sed s/\.bam//`
	echo "bamCoverage --bam ${j}.bam -of bigwig -o ${j}.SeqDepthNorm.bw --binSize 10 --normalizeTo1x 2150570000 --ignoreForNormalization chrX --extendReads 150 --centerReads --smoothLength 30" >> bamcoverage_command
done
#############################################################################################################################

for i in *.bam
do
	j=`echo $i | sed s/\.bam//`
	echo "bamCoverage --bam ${j}.bam -of bigwig -o ${j}.RPKMNormalized.bw --binSize 10  --normalizeUsingRPKM --ignoreForNormalization chrX --extendReads 150 --centerReads --smoothLength 30" >> bamcoverage_command_RPKM
done
