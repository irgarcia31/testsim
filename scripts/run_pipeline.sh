# place here any commands that need to be run before analysing the samples

cd /home/user14/Desktop/testsim/testsim
export WD=$(pwd)

mkdir res/genome

echo "Downloading Genome..."
wget -O res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip -k res/genome/ecoli.fasta.gz

echo "Running STAR index..."
    mkdir -p res/genome/star_index
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir res/genome/star_index/ --genomeFastaFiles res/genome/ecoli.fasta --genomeSAindexNbases 9
    echo

for sampleid in $(ls data/*.fastq.gz | cut -d "_" -f1 | sed 's:data/::' | sort | uniq)
do
	echo "Running FastQC..."
	mkdir -p out/fastqc
	fastqc -o out/fastqc data/${sampleid}*.fastq.gz
	echo
	echo "Running cutadapt..."
	mkdir -p log/cutadapt
	mkdir -p out/cutadapt
	cutadapt -m 20 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o out/cutadapt/${sampleid}_1.trimmed.fastq.gz -p out/cutadapt/${sampleid}_2.trimmed.fastq.gz data/${sampleid}_1.fastq.gz data/${sampleid}_2.fastq.gz > log/cutadapt/${sampleid}.log
	echo
	echo "Running STAR alignment..."
	mkdir -p out/star/${sampleid}
	STAR --runThreadN 4 --genomeDir res/genome/star_index/ --readFilesIn out/cutadapt/${sampleid}_1.trimmed.fastq.gz out/cutadapt/${sampleid}_2.trimmed.fastq.gz --readFilesCommand zcat --outFileNamePrefix out/star/${sampleid}/
	echo

# place here the script with commands to analyse each sample
# this command should receive the sample ID as the only argument

done

# place here any commands that need to run after analysing the samples

	echo "Creating a report with MultiQC..."
	multiqc -o out/multiqc $WD
	cd out/multiqc/
	firefox multiqc_report.html

echo "THE END!"
