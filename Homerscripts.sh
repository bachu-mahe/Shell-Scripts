#! /bin/bash

for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "makeTagDirectory ${j}/ ${j}.bed -format bed" >> mkdir_command
done
#############################################################################################################################


for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "findPeaks ${j} -style histone -o auto -i Input_R1.trimmed_sorted_rmdup -o ${j}.regions.txt" >> find_peak_histone
done
#############################################################################################################################

for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "findPeaks ${j} -size 1000 -i Input_R1.trimmed_sorted_rmdup -o ${j}/${j}.1kb_formotiff.txt" >> find_peak_histone_motiff
done
#############################################################################################################################


for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "findPeaks ${j} -style super -o auto -i Input_R1.trimmed_sorted_rmdup -o ${j}/${j}.Super_enhancer.txt" >> find_peak_super
done
#############################################################################################################################
for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "findPeaks ${j} -o auto -nfr -C 0 " >> find_peak_Mnase
done
#############################################################################################################################

for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "findMotifsGenome.pl ${j}/${j}.1kb_formotiff.txt mm9 ${j}-Peak_MotifOutput_200bpsize/ -size 200 -len 6,8,10 -S 15" >> find_motif
done
#############################################################################################################################
for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "annotatePeaks.pl ${j}.Hist.txt mm9 > ${j}.Hist.Peak-annotattion.txt" >> annotate_peaks
done
#############################################################################################################################
for i in *.bed; do j=`echo $i | sed s/\.bed//`; echo "makeUCSCfile ${j}/ -o auto -bigWig mm9.chrom.sizes -fsize 1e20 -res 10 > ${j}.bigWig.trackInfo.txt" >> make_UCSC ; done
#############################################################################################################################
for i in *.bed
do
	j=`echo $i | sed s/\.bed//`
	echo "makeMetaGeneProfile.pl rna mm9 -p ${j}/regions.txt > ${j}_MetaGeneProfile.txt" >> metaGene_Profile
done
#############################################################################################################################


for i in *.bed; do j=`echo $i | sed s/\.bed//`; echo "makeUCSCfile ${j}/ -o auto -bigWig mm9.chrom.sizes -fsize 1e20 -res 1 > ${j}.bigWig.trackInfo.txt" >> make_UCSC ; done

#############################################################################################################################

Quantify gene expression across all experiments for clustering and reporting (-rpkm):
# May also wish to use "-condenseGenes" if you don't want multiple isoforms per gene

for i in *.bam
do
analyzeRepeats.pl rna mm9 -strand both -count exons -d \
	RO1_RNA_Seq/ \
	RO2_RNA_Seq/ \
	RO3_RNA_Seq/ \
	RO4_RNA_Seq/ \
	RO5_RNA_Seq/ \
	RO6_RNA_Seq/ \
	RO7_RNA_Seq/ \
	RO8_RNA_Seq/ \
	RO9_RNA_Seq/ \
	RO10_RNA_Seq/ \
	RO11_RNA_Seq/ \
	RO12_RNA_Seq/ \
	RO13_RNA_Seq/ \
	RO15_RNA_Seq/ \
	RO16_RNA_Seq/ \
	-rpkm > RNA_Seq_rpkm.txt
#############################################################################################################################
