#!/bin/bash

# Default values
length=200

# Function to display script usage
usage() {
    echo
    echo "###############################################"
    echo "#                                             #"
    echo "#               Help Information              #"
    echo "#                                             #"
    echo "###############################################"
    echo
    echo "Usage:"
    echo -e "\t$0 [OPTIONS] ARGUMENT"
    echo
    echo "Description:"
    echo -e "\tThis script will take a known reference genome (.fa) and provided single nucleotide polymorphisms (SNPs)"
    echo -e "\tand report them back as ormatted SNP with flanking sequences. Input files must contain the chromosome, position"
    echo -e "\treference allele, alternate allele, and id of each SNP per each line of the input file. Input files must be"
    echo -e "\ttab delimited and the order of the columns is irrelivant"
    echo 
    echo "Options:"
    echo -e "\t-h, --help              Display this help and exit"
    echo -e "\t-v, --verbose           Display text feedback (default option is false)"
    echo 
    echo "Arguments:"
    echo -e "\t-i, --input-file        Input file (tab-delimited)"
    echo -e "\t-o, --output-file       Name of the output file (tab-delimited)"
    echo -e "\t-l, --length            Length in bp (default is 200)"
    echo -e "\t-r, --reference-geno    Reference genome file (.fa)"
    echo
    echo "Examples:"
    echo -e "\t$0 -i 'input_file.txt' -l 200 -r 'reference_genome.fa'"
    exit 1
}

# Set verbose to false automatically
verbose=false
first_row=true

# Parse command-line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -i|--input-file)
            input_file="$2"
            shift
            shift
            ;;
        -o|--output_file)
            output_file="$2"
            shift
            shift
            ;;            
        -l|--length)
            length="$2"
            shift
            shift
            ;;
        -r|--reference-geno)
            reference_geno="$2"
            shift
            shift
            ;;
        -h|--help)
            usage
            ;;
        -v|--verbose)
            verbose=true
            shift
            shift            
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Pull script path
path_to_script=$(dirname "$0")

# Check to make sure dependencies exist
if [ ! -f "$path_to_script/snp_sequence_puller.sh" ]; then
    echo "Error: snp_sequence_puller.sh does not exist in the script directory. Check the scripts directory."
    exit 1
fi

# Check if required options are provided
if [ -z "$input_file" ] || [ -z "$reference_geno" ]; then
    echo "Error: Input file and reference genome file are required."
    usage
fi

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found."
    exit 1
fi

if [ "$verbose" = true ]; then
    # Print header
    echo
    echo "###############################################"
    echo "#                                             #"
    echo "#          SNP Sequence Puller v1.0           #"
    echo "#                                             #"
    echo "###############################################"
    echo
    echo "Written by: Zachary J. Winn PhD"
    echo "Contact information:"
    echo -e "\tGovernment Email: zachary.winn@usda.gov"
    echo -e "\tPersonal Email: zwinn@outlook.com"
    echo
    echo "###############################################"
    echo "# WARNING: This program is not under warranty #"
    echo "#          Use at your own discretion!        #"
    echo "###############################################"
    echo
fi

# Set options
first_row=true

# Read header to get column names
IFS=$'\t' read -r -a headers < "$input_file"

# Find indices of desired columns
chr_index=-1
pos_index=-1
ref_index=-1
alt_index=-1
id_index=-1
for i in "${!headers[@]}"; do
    # Trim whitespace from the column name
    column_name=$(echo "${headers[$i]}" | tr -d '[:space:]')
    if [[ "$column_name" == "chr" ]]; then
        chr_index=$i
    elif [[ "$column_name" == "pos" ]]; then
        pos_index=$i
    elif [[ "$column_name" == "ref" ]]; then
        ref_index=$i
    elif [[ "$column_name" == "alt" ]]; then
        alt_index=$i
    elif [[ "$column_name" == "id" ]]; then
        id_index=$i
    fi
done

# Check if all desired columns are found
if [[ $chr_index == -1 || $pos_index == -1 || $ref_index == -1 || $alt_index == -1 || $id_index == -1 ]]; then
    echo "Error: Not all required columns (chr, pos, ref, alt, id) found in the input file."
    exit 1
fi

if [ "$verbose" = true ]; then
    echo "###############################"
    echo "# Header read in succesfully! #"
    echo "###############################"
    echo
fi

if [ "$verbose" = true ]; then
    echo "#############################################"
    echo "# Pulling SNP sequences from input files... #"
    echo "#############################################"
    echo
fi

# Open the file for reading
while IFS=$'\t' read -r -a row; do
   
    # Check if it's the first row and skip it
    if $first_row; then
        first_row=false
        # Add header to the output file
        echo -e "chr\tpos\tid\tref\talt\tsnp_sequence" > "$output_file"
        continue
    fi
    
    # Extract data from the desired columns
    chr="${row[$chr_index]}"
    pos="${row[$pos_index]}"
    ref="${row[$ref_index]}"
    alt="${row[$alt_index]}"
    id="${row[$id_index]}"

    # Remove white space
    alt="${alt%"${alt##*[![:space:]]}"}"
    alt="${alt#"${alt%%[![:space:]]*}"}"

    # Remove white space
    ref="${ref%"${ref##*[![:space:]]}"}"
    ref="${ref#"${ref%%[![:space:]]*}"}"

    # Run command and capture output
    sequence_output=$(bash "$path_to_script/snp_sequence_puller.sh" \
        -f "$reference_geno" \
        -p "$pos" \
        -l "$length" \
        -c "$chr" \
        -a "$alt" \
        -r "$ref")

    # Append to output file with tab delimiter
    echo -e "$chr\t$pos\t$id\t$ref\t$alt\t$sequence_output" >> "$output_file"
    
done < "$input_file"

if [ "$verbose" = true ]; then
    # Print message
    echo "#########"
    echo "# Done! #"
    echo "#########"
    echo
fi

exit 0