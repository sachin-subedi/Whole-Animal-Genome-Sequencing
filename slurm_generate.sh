#!/bin/bash
#SBATCH --job-name=wags_prep_subs
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64gb
#SBATCH --time=7-00:00:00
#SBATCH --output=log.%j.out
#SBATCH --error=log.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ss11645@uga.edu

cd $SLURM_SUBMIT_DIR

ml purge
ml Mamba/23.1.0-4

export PATH=${HOME}/minio-binaries:$PATH

source ~/.bashrc
conda activate snakemake

python /scratch/ss11645/LC/SRA/prefetchData/sra/wags/wags/prep_subs.py \
--meta /scratch/ss11645/LC/SRA/prefetchData/sra/download_data/input.csv \
--fastqs /scratch/ss11645/LC/SRA/prefetchData/sra/download_data/ \
--ref canfam4 \
--out /scratch/ss11645/LC/SRA/prefetchData/sra/download_data/out \
--bucket RESULTS \
--snake-env snakemake \
--partition batch \
--email ss11645@uga.edu \
--account laclab \
--remote local \
--alias MINIO_ALIAS


