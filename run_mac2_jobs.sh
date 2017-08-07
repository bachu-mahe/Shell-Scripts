#!/bin/bash
# Run like this:
# ./run_macs2_jobs Some_Input.bam
Input_filename=$1 # specify the input as the argument of the function 
> macs2_jobs
ls *.bam | grep -v ${Input_filename} | while read IP_filename
do 
	exp_label="${IP_filename:0:${#IP_filename}-4}"
	echo "macs2 callpeak -t ${IP_filename} -c ${Input_filename} --broad -g mm --name ${exp_label} --outdir Macs_Output --bdg --broad-cutoff 0.1" >> macs2_jobs
done
swarm -f macs2_jobs -g 8 --module macs