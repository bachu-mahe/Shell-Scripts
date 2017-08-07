#############################################################################################################################	


for x in *.bam
do
	j="${x:0:${#x}-4}"
	#mkdir ${j}
	cd ${j}
	cp -r /usr/local/apps/sicer/1.1/ex .
	echo "cd /data/bachum/data/Ryota_H3K36me3/Ryota_Merged_Fastqs_Zymnd11_Input/${j}; sh $SICERDIR/SICER.sh . ../${j}.bed ../ty5.sorted.bed . mm9 1 200 150 0.787 600 .01"
	cd ..
done

#############################################################################################################################	

for x in *.bed
do
	j="${x:0:${#x}-4}"
	mkdir ${j}
	cd ${j}
	cp -r /usr/local/apps/sicer/1.1/ex .
	echo "cd /data/bachum/data/Ryota_H3K36me3/161019_NB501202_0031_AHGMH2BGXY/Data/Intensities/BaseCalls/Fastq_Files/Bed_Files/${j}; sh SICERDIR/SICER.sh . ../${j}.bed ../Input_R1.trimmed_sorted_rmdup.bed . mm9 1 200 150 0.787 600 .01"
	cd ..
done

#############################################################################################################################	

for x in *.bam
do
	j="${x:0:${#x}-4}"
	echo "Rscript run_spp.R -c=${j}.bam -savp=${j}.spp.pdf -out=${j}-sppR.out"
done

#############################################################################################################################	




for x in *.bam
do
	j="${x:0:${#x}-4}"
    #mkdir ./Macs_Peak_Analysis/${j}-Macs-BroadPeak
	#echo "macs2 predictd -i ${j}.bed -g mm --outdir ${j}-Macs-fragsize --rfile ${j} -m 10 30"
	echo "macs2 callpeak -t ${j}.bam -c Input_R1.trimmed_sorted_rmdup.bam -g mm -n ${j} --outdir ${j}-Macs-BroadPeak -B -f BAM --broad --keep-dup auto --nomodel --extsize "200""
done
#############################################################################################################################	

for x in *.bam
do
	j="${x:0:${#x}-4}"
	echo "macs2 bdgcmp -t ./Macs_Peak_Analysis/${j}-Macs-BroadPeak/${j}_treat_pileup.bdg -c ./Macs_Peak_Analysis/${j}-Macs-BroadPeak/${j}_control_lambda.bdg -o ${j}_FE.bdg -m FE" >> FE_command
done

#############################################################################################################################	

for x in *.bam
do
	j="${x:0:${#x}-4}"
	echo "macs2 bdgcmp -t ./Macs_Peak_Analysis/${j}-Macs-BroadPeak/${j}_treat_pileup.bdg -c ./Macs_Peak_Analysis/${j}-Macs-BroadPeak/${j}_control_lambda.bdg -o ${j}_logLR.bdg -m logLR -p 0.00001" >> log2_command
done
#############################################################################################################################	


for i in *_logLR.bdg
do
	j=`echo $i | sed s/\_logLR.bdg//`
	echo "bedtools slop -i ${j}_logLR.bdg -g mm9.Chrom.Sizes -b 0 | bedClip stdin mm9.Chrom.Sizes ${j}_logLR.clip; bedGraphToBigWig ${j}_logLR.clip mm9.Chrom.Sizes ${j}_logLR.bw" >> log2_bwtrack
done
#############################################################################################################################	

for i in *_FE.bdg
do
	j=`echo $i | sed s/\_FE.bdg//`
	echo "bedtools slop -i ${j}_FE.bdg -g mm9.Chrom.Sizes -b 0 | bedClip stdin mm9.Chrom.Sizes ${j}_FE.clip && LC_COLLATE=C sort -k1,1 -k2,2n ${j}_FE.clip > ${j}.sorted.clip && bedGraphToBigWig ${j}_FE.clip mm9.Chrom.Sizes ${j}_FE.bw" >> FE_bwtrack
done
#############################################################################################################################	
