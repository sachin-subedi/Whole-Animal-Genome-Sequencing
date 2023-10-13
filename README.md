# Whole-Animal-Genome-Sequencing

## Project Objective:

Utilizing the pipeline provided by our collaborators, we are able to generate GVCF outputs. Our process involves amalgamating 30 distinct GVCF files. For alignment of the raw data, we've selected the CanFam4 reference genome, a well-established reference for canine genetic research. Detailed protocols and methodologies for this pipeline can be accessed at: https://github.com/jonahcullen/wags. I have procured raw genomic data for both Collies and Shetland Sheepdogs (often referred to as Shelties) from the Sequence Read Archive (SRA). This data was then systematically aligned to CanFam4 using the WAGS pipeline. The result of this alignment is a GVCF file, which we then integrate with other GVCF files. Our overarching objective is to establish a comprehensive reference panel comprising genomes from all accessible Collie and Sheltie samples. This meticulously constructed panel will facilitate the imputation of data from low-pass sequencing or SNP arrays, aligning it with the whole genome sequence.

### Reated paper:
https://doi.org/10.1093/g3journal/jkad117


## Using GACRC Sapelo2 Cluster
The required dependencies are as follows:
1. Python
2. Mamba or Conda
3. Snakemake
4. Snakemake-Profiles
5. Miscellaneous Python modules pyaml, wget, and xlsxwriter
6. Apptainer/Singularity
7. MinIO Client

There are two options for the SRA toolkit in Sapelo2:
```bash
ml spider SRA-Toolkit
```
This command will show that currently there are these two versions installed:
```bash    
SRA-Toolkit/3.0.1-centos_linux64
SRA-Toolkit/3.0.3-gompi-2022a
```

Then, load the SRA-Toolkit module and run the commands.

## Download the container
wget https://s3.msi.umn.edu/wags/wags.sif

### Visualizing the container having reference genome:

```bash
interact --mem=10gb -c 4
singularity exec /scratch/ss11645/LC/wags.sif tree /home/refgen/ -L 2
```
### Cloning WAGS repository:
git clone https://github.com/jonahcullen/wags.git


## SRA to FASTQ:
Initiate interactive environment:
```bash
interact -c 8 --mem 32gb -p batch
```
I have installed it on Sapelo2. Its module name is:
```bash
parallel-fastq-dump/0.6.7-gompi-2022a
```
When you load it, the SRA-Toolkit/3.0.3-gompi-2022a module and one of its dependencies will be loaded. You can use its --threads option to achieve some-fold performance gain, for example:
```bash
parallel-fastq-dump --sra-id SRR2244401 --threads 8 --outdir out/ --split-files --gzip
```
The bash script is named FASTQ.sh
```bash
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
```

### What if Conda/Mamba is not needed?

You can try the following modules to run the Wags pipeline:
```bash 
Python/3.10.4-GCCcore-11.3.0
snakemake/7.22.0-foss-2022a
PyYAML/6.0-GCCcore-11.3.0
wget-util/3.2-GCCcore-11.3.0-Python-3.10.4
XlsxWriter/3.0.8-GCCcore-11.3.0
```
You don't need Mamba or Conda because they are for installing smakemake and PyYAML, wget, XlsxWriter Python modules, which are already installed as the central modules listed above. As for Apptainer or Singularity, they are also installed and ready for use on Sapelo2. So, we have the last two dependencies to handle: snakemake-profiles and MiniIO Client. As for MiniIO Client, you can download and install it in your home dir on Sapelo2, following the instructions given at https://min.io/docs/minio/linux/reference/minio-mc.html :
64-bit Intel:
```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help  (type "q" to quite_from Zhuofei)
mc -v

```

As for snakemake-profiles, I think it is optional and you can run the wags pipeline without it (by not using the wags' --profile option).


### Conda/Mamba is needed?

I have configured its environment for you on the cluster. What I did:

1. Using Mamba/23.1.0-4 to create a snakelike env (including pyyaml, wget, xlsxwriter etc. dependencies) at  
/home/ss11645/.conda/envs/snakemake/


2. Cleaned up your ~/.bashrc file:

I commented on two lines in your .bashrc. I put "# commented by ZH.2023.10.10" on the top of each line I commented out. The two lines that I commented on are not needed.

3. To enable wags pipeline scripts to use the snakemake env I created in step 1 above, I put a conda initialization block at the bottom of .bashrc. Its purpose is only for running the wag pipeline. You can permanently remove this block from your .bashrc file when you want to.
```bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# commented by ZH.2023.10.10
# echo 'export PATH="/path/to/miniconda3/bin:$PATH"' >> ~/.bashrc

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '

# commented by ZH.2023.10.10
# export PATH="/path/to/miniconda3/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/apps/eb/Mamba/23.1.0-4/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/apps/eb/Mamba/23.1.0-4/etc/profile.d/conda.sh" ]; then
        . "/apps/eb/Mamba/23.1.0-4/etc/profile.d/conda.sh"
    else
        export PATH="/apps/eb/Mamba/23.1.0-4/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```
4. In your /scratch/ss11645/LC/SRA/prefetchData/sra/wags folder, there is a file called sourcrME. You will source this file before running pipeline scripts. 

The .basrc files is given by .basrc

## FASTQ to GVCF (OneWAG)

The input file is given by input.csv.

| dogid      | breed           | gender| fastq_id|
|------------|-----------------|---|-----------|
| ERR11203059| ShetlandSheepDog| NA|ERR11203059|

FASTQs located in /scratch/ss11645/LC/SRA/prefetchData/sra/download_data/
We ran prep_subs.py in cluster combining with bash script as slurm_generate.sh.
```bash
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
```


The scripts will now generate separate pipelines with each pipelines can then be initiated with sbatch ShetlandSheepDog_ERR12345678.one_wag.slurm. Here is one example:

```bash
#!/bin/bash

#SBATCH --job-name=Collie_ERR11223859.one_wag.slurm
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=50gb
#SBATCH --time=60:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ss11645@uga.edu
#SBATCH -o slurm_logs/%j.Collie_ERR11223859.one_wag.out
#SBATCH -e slurm_logs/%j.Collie_ERR11223859.one_wag.err
#SBATCH -A laclab
#SBATCH -p batch


source ~/.bashrc
conda activate snakemake
cd $SLURM_SUBMIT_DIR


FQ_DIR=/scratch/ss11645/LC/SRA/prefetchData/sra/download_data
PROC_DIR=/scratch/ss11645/LC/SRA/prefetchData/sra/download_data/out 



# extract reference dict from container
singularity exec --bind $PWD /home/ss11645/.sif/wags.sif \
    cp /home/refgen/dog/canfam4/canFam4.dict $PWD


snakemake -s one_wag.smk \
    --use-singularity \
    --singularity-args "-B $PWD,$REF_DIR,$POP_VCF,$FQ_DIR,$PROC_DIR" \
    --profile slurm.go_wags \
    --configfile canfam4_config.yaml \
    --keep-going
```
## Basic Error terms:

1. Please do not load or run the SRA-Toolkit commands directly on the Sapelo2 login node. If you want to run it interactively, please first start an interactive session. For example, use interact --mem=10gb -c 4. 

2. Previously, I thought you didn't need Mamba or Conda to install snakemake and other modules, and you can load and use the central modules we have installed on Sapelo2. Later I realized if we do this we need to change 3 pipeline scripts in wags sub-folder: prep_custom_ref.py, prep_joint.py, prep_subs.py

3. Introducing any modifications to the current pipeline's scripts usually is not what we want to do or need to do. So, I followed instructions given at https://github.com/jonahcullen/wags to create a env for snakemake and other decencies.

4. On the top of your script, if you use  #!/bin/bash then you need to do source manually in your script before activating your env: source ~/.bashrc. But if you use #!/bin/bash -l, on the top of your script, then you will not need to do source manually in your script before activating your env, since the -l option of bash will tell bash to invoke a login shell for running job and the ~/.bashrc file will be sourced automatically when the shell is started.

5. You can test with the following line removed from your job submission script: 
set -e. Using set -e, the subshell running your job will exit immediately if a command returns a non-zero status in your job, which could cause an empty log file.

6. https://github.com/ncbi/sra-tools/issues

7. For the batch submission script, please change ntasks=48 to ntasks=1, as this is not a program that can run with multiple tasks. The fastq-dump command can use multithreads, and you can request multiple cores to run the multithreads using the cpus-per-task option.

8. Some useful links
https://www.biostars.org/p/9498951/ 
https://github.com/rvalieris/parallel-fastq-dump
https://github.com/rvalieris/parallel-fastq-dump#micro-benchmark











