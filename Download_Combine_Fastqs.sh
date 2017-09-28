#! /bin/bash

wget --input-file=download_links.txt --recursive --level=2 --no-host-directories --cut-dirs=5 --accept csv,gz
echo
echo "Download complete. Starting to unpack gz files."

find . -type d | grep -v '^.$' | while read x
do
	cd "$x"
	echo "Moving to folder ${x:2:${#x}-2}."
	ls *.gz | while read fn
		do 
			fastq_name="${fn:0:${#fn}-3}"
			echo -ne "Unpacking ${fastq_name}.gz -> ${fastq_name}... "
			gunzip -c "${fastq_name}.gz" > "${fastq_name}"
			echo "done."
done
		
	echo "Unpacking done. Combining files now..."
	# folder name example ./Sample_JO_101714_9
	# sample name: JO_101714_9
	sample_name="${x:9:${#x}-9}"
	echo -ne "Combining R1 files... "
	cat *R1*.fastq > "${sample_name}_R1.fastq"
	echo "done."
	echo -ne "Combining R2 files... "
	cat *R2*.fastq > "${sample_name}_R2.fastq"
	echo "done."
	echo
	cd ..
done
