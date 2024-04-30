# Introduction
Single nucleotide polymorphisms (SNPs) are single nucleotide base-pair exchanges that occur genome wide in all living organisms. These SNPs can be used to design polymerase chain reaction (PCR) molecular markers. This program takes a reference genome, an alternate allele at a SNP site, and a specified flanking sequence length. The program then takes those inputs and outputs a sequence which is of some length with a centeralized SNP in the middle of the strand (I.E., ATTAG[C\T]GTACG). This output can then be taken and used in downstream process of molecular marker design. 

# Featured Scripts
There are two shell scripts written to acomplish the required task of pulling flanking sequences around SNPs and formatting them into an output:
1. [snp_sequence_puller.sh](https://github.com/zjwinn/SNP-Sequence-Puller/blob/main/snp_sequence_puller.sh)
2. [snp_sequence_puller_auto.sh](https://github.com/zjwinn/SNP-Sequence-Puller/blob/main/snp_sequence_puller_auto.sh)

The snp_sequence_puller.sh script takes a single provided SNP/position and returns a SNP with flanking sequence. The snp_sequence_puller_auto.sh script takes a tab delmited file of SNPs with genomic positions and provides back a tab delmited file of SNPs with genomic positions. The main function for this repository is the snp_sequence_puller_auto.sh, but it is dependent on snp_sequence_puller.sh. If snp_sequence_puller.sh and snp_sequence_puller_auto.sh are not found in the same directory, then snp_sequence_puller_auto.sh will throw an error message and fail to complete.   

# Requirments
There are several requirments of both functions. Below I will detail the required inputs of both functions.

## snp_sequence_puller.sh
The snp_sequence_puller.sh function requires several inputs to properly function. Below is a discritpion of the flags.

1. **-f, --genome-file:**  
   - Input reference genome file. This should be a fasta (.fa) file and the fasta file should come with an index (.fai). If the index is not present, this code will create one. If you do not have writing privileges in the directory of your reference genome, then the function may fail due to not being able to write an index if one is not present.

2. **-p, --position:**  
   - Position in the reference genome. This should be an integer ranging from 0 to the end of the chromosome length.

3. **-l, --length:**  
   - Flanking sequence length. This is the length in base pairs around your SNP. Note, if you provide a length longer than the amount of base pairs on either side, you will be greeted with an error message.

4. **-c, --chromosome:**  
   - Chromosome in reference genome. This must match the chromosome names provided in the reference (e.g., Chr1A vs. 1A).

5. **-a, --alternate-allele:**  
   - Alternate allele of provided position. This must be a single nucleotide sequence. This must be an A, T, G, or C.

6. **-r, --reference-allele:**  
   - Reference allele of provided position. This must be a single nucleotide sequence. This must be an A, T, G, or C.

## snp_sequence_puller_auto.sh
The snp_sequence_puller_auto.sh uses snp_sequence_puller.sh to recursivly perform the above task for every listed sequence in a tab delimited file. Below is a discription of the flags.

1. **-i, --input-file:**  
  - Input tab delmited file (e.g., input_file.txt)
    
2. **-o, --output-file:**  
  - Name of the tab delimited output file (e.g., output_file.txt)

3. **-l, --length:**
  - Length in bp (default is 200). This is the length of the flanking sequence you want around your SNP. 

4. **-r, --reference-geno:**  
  - Input reference genome file. This should be a fasta (.fa) file and the fasta file should come with an index (.fai). If the index is not present, this code will create one. If you do not have writing privileges in the directory of your reference genome, then the function may fail due to not being able to write an index if one is not present.
