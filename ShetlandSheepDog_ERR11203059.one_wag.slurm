#!/bin/bash -l
#SBATCH --job-name=ShetlandSheepDog_ERR11203059.one_wag.slurm
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=50gb
#SBATCH --time=60:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ss11645@uga.edu
#SBATCH -o slurm_logs/%j.ShetlandSheepDog_ERR11203059.one_wag.out
#SBATCH -e slurm_logs/%j.ShetlandSheepDog_ERR11203059.one_wag.err
#SBATCH -A laclab
#SBATCH -p batch


source ~/.bashrc
conda activate snakemake
cd $SLURM_SUBMIT_DIR

export _JAVA_OPTIONS=-Djava.io.tmpdir=/scratch/ss11645/LC/SRA/prefetchData/sra/wags2/DTA/download_data/out/.fastq/ShetlandSheepDog/ERR11203059/.tmp
FQ_DIR=/scratch/ss11645/LC/SRA/prefetchData/sra/wags2/DTA/download_data
PROC_DIR=/scratch/ss11645/LC/SRA/prefetchData/sra/wags2/DTA/download_data/out 

# extract reference dict from container
singularity exec --bind $PWD /home/ss11645/.sif/wags.sif \
    cp /home/refgen/dog/canfam4/canFam4.dict $PWD


snakemake -s one_wag.smk \
    --use-singularity \
    --singularity-args "-B $PWD,$REF_DIR,$POP_VCF,$FQ_DIR,$PROC_DIR" \
    --profile slurm.go_wags \
    --configfile canfam4_config.yaml \
    --keep-going
