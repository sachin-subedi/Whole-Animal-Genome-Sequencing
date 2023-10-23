#!/bin/bash
#SBATCH --job-name=fastq-dump_job
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=80gb
#SBATCH --time=120:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ss11645@uga.edu
#SBATCH -o slurm_logs/%x_%j.out
#SBATCH -e slurm_logs/%x_%j.err

# Load the SRA Toolkit module
ml SRA-Toolkit/3.0.1-centos_linux64

# Replace 'SRA_ID_HERE' with the actual SRA ID you want to download
SRA_ID_HERE="ERR11203059"

# Define the output directory
OUTPUT_DIR="download_data"

# Use fastq-dump to download SRA data
fastq-dump --split-files --gzip --outdir "$OUTPUT_DIR" "$SRA_ID_HERE"
