#!/bin/bash

# Function to display script usage
usage() {
    echo "Usage: $0 -f <genome_file> -p <position> -l <flanking_length> [-c <chromosome>] [-a <alternate_allele>] [-v]"
    echo "  -f, --genome-file       Input genome file"
    echo "  -p, --position          Position in the genome"
    echo "  -l, --length            Flanking sequence length"
    echo "  -c, --chromosome        Chromosome"
    echo "  -a, --alternate-allele  Alternate allele"
    echo "  -v, --verbose           Enable verbose mode"
    echo "  -h, --help              Display this help and exit"
    echo
    echo "This script comes with no warranty. Use it at your own discretion."
    exit 1
}

# Default values
verbose=false


# Parse command line options
while getopts ":f:p:l:c:a:vh" opt; do
    case ${opt} in
        f | --genome-file )
            genome_file="$OPTARG"
            ;;
        p | --position )
            position="$OPTARG"
            ;;
        l | --length )
            flanking_length="$OPTARG"
            ;;
        c | --chromosome )
            chromosome="$OPTARG"
            ;;
        a | --alternate-allele )
            alternate_allele="$OPTARG"
            ;;
        v | --verbose )
            verbose=true
            ;;
        h | --help )
            usage
            ;;
        \? )
            echo "Error: Invalid option -$OPTARG" 1>&2
            usage
            ;;
        : )
            echo "Error: Option -$OPTARG requires an argument" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

if [ "$verbose" = true ]; then
    # Print header
    echo "###############################################"
    echo "#                                             #"
    echo "#          SNP Sequence Puller v1.0           #"
    echo "#                                             #"
    echo "###############################################"
    echo
    echo "Written by: Zachary Winn"
    echo "Contact information:"
    echo -e "\tEmail: zachary.winn@usda.gov"
    echo
    echo "###############################################"
    echo "# WARNING: This program is not under warranty #"
    echo "#          Use at your own discretion!        #"
    echo "###############################################"
    echo
fi

# Check if all required options are provided
if [ -z "$genome_file" ] || [ -z "$position" ] || [ -z "$flanking_length" ]; then
    echo "Error: Missing required options."
    usage
fi

# Check if genome file exists
if [ ! -f "$genome_file" ]; then
    echo "Error: Genome file '$genome_file' not found."
    exit 1
fi

# Check if position is a positive integer
if ! [[ "$position" =~ ^[0-9]+$ ]]; then
    echo "Error: Position should be a positive integer."
    exit 1
fi

# Check if flanking length is a positive integer
if ! [[ "$flanking_length" =~ ^[0-9]+$ ]]; then
    echo "Error: Flanking length should be a positive integer."
    exit 1
fi

# Check if alternate allele is provided and is valid
if [ -n "$alternate_allele" ]; then
    if [[ ! "$alternate_allele" =~ ^[ATGC]$ ]]; then
        echo "Error: Alternate allele must be one of A, T, G, or C."
        exit 1
    fi
fi

# Check if position - flanking_length is less than 0
if ((position - flanking_length < 0)); then
    echo "Error: Flanking length too long for genome position."
    exit 1
fi


# Create a temporary BED file with the specified coordinates
start=$((position - flanking_length-1))
end=$((position + flanking_length))
echo -e "$chromosome\t$start\t$end" > temp.bed

# Check verbose
if [ "$verbose" = true ]; then
    echo "Extracting sequence for chromosome $chromosome, position $position with flanking length of $flanking_length..."
    echo
fi

# Extract sequence with bedtools
extracted_sequence=$(bedtools getfasta -fi "$genome_file" -bed temp.bed | awk 'NR==2')

# Replace the position with [ref/alt]
ref_allele="${extracted_sequence:$flanking_length:1}"

# Check if ref_allele and alternate_allele are single-letter characters and do not match each other
if [[ ${#ref_allele} -eq 1 && ${#alternate_allele} -eq 1 && $ref_allele != $alternate_allele ]]; then
    :
else
    echo "'Error: reference and alternate alleles must be single-letter characters and must not match each other (E.G., Reference allele = "$ref_allele"; Alternate allele = "$alternate_allele").'"
    exit 1
fi

# Calculate the index of the SNP in the extracted sequence
snp_index=$((flanking_length))

# Replace the position with [ref/alt]
extracted_sequence="${extracted_sequence:0:$snp_index}[$ref_allele/$alternate_allele]${extracted_sequence:$snp_index+1}"

# Check verbose
if [ "$verbose" = true ]; then
echo "=============================================="
echo "Genome sequence SNP at position = $position is [$ref_allele/$alternate_allele]"
echo "with flanking length of $flanking_length"
echo "on chromosome $chromosome"
echo "=============================================="
echo
fi

# Report extracted sequence
echo "$extracted_sequence"

# Remove the temporary BED file
rm temp.bed
