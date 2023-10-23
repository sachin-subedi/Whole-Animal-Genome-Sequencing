#!/bin/bash
#SBATCH --job-name=parallel-fastq-dump_job
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=80gb
#SBATCH --time=120:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ss11645@uga.edu
#SBATCH -o slurm_logs/%x_%j.out
#SBATCH -e slurm_logs/%x_%j.err

ml parallel-fastq-dump/0.6.7-gompi-2022a

parallel-fastq-dump --sra-id ERR11203060 --threads 10 --outdir download_data --split-files --gzip