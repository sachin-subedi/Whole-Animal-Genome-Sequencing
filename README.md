# Whole-Animal-Genome-Sequencing

## Project Objective:

•	Use pipeline from collaborators that give GVCF and combine 30 GVCF files.

•	The pipeline the collaborators made to align raw data to CanFam4 is the reference genome for the dog we chose to use.  

•	The pipeline is: https://github.com/jonahcullen/wags

•	I can download raw data from Collies and Shetland Sheepdogs (aka Shelties) deposited into SRA and then use WAGS to align them to CanFam4. It will output a gvcf, which can then be combined with other gvcf files.  

•	The ultimate goal is to have a reference panel of all available collie and Sheltie genomes. 

•	We could impute low-pass sequencing or SNP array data to the whole genome sequence with this reference panel. 

## Using GACRC Sapelo2 Cluster

The required dependencies are as follows:
•	Python
•	Mamba or Conda
•	Snakemake
•	Snakemake-Profiles
•	Miscellaneous Python modules pyaml, wget, and xlsxwriter
•	Apptainer/Singularity
•	MinIO Client

There are two options for the SRA toolkit in Sapelo2:

ml spider SRA-Toolkit

This command will show that currently there are these two versions installed:
    
        SRA-Toolkit/3.0.1-centos_linux64
        SRA-Toolkit/3.0.3-gompi-2022a


Then, load the SRA-Toolkit module and run the commands.

## Download the container
wget https://s3.msi.umn.edu/wags/wags.sif

Visualizing the container having reference genome:

interact --mem=10gb -c 4

singularity exec /scratch/ss11645/LC/wags.sif tree /home/refgen/ -L 2


 Cloning WAGS repository:
git clone https://github.com/jonahcullen/wags.git


## SRA to FASTQ:

Initiate interactive environment:
interact -c 8 --mem 32gb -p batch

It have installed it on Sapelo2. Its module name is:

parallel-fastq-dump/0.6.7-gompi-2022a

When you load it, the SRA-Toolkit/3.0.3-gompi-2022a module and one of its dependencies will be loaded. You can use its --threads option to achieve some-fold performance gain, for example:

parallel-fastq-dump --sra-id SRR2244401 --threads 8 --outdir out/ --split-files --gzip

The bash script is named FASTQ.sh



### What if Conda/Mamba is not needed?

You can try the following modules to run the Wags pipeline: 
Python/3.10.4-GCCcore-11.3.0
snakemake/7.22.0-foss-2022a
PyYAML/6.0-GCCcore-11.3.0
wget-util/3.2-GCCcore-11.3.0-Python-3.10.4
XlsxWriter/3.0.8-GCCcore-11.3.0

You don't need Mamba or Conda because they are for installing smakemake and PyYAML, wget, XlsxWriter Python modules, which are already installed as the central modules listed above.

As for Apptainer or Singularity, they are also installed and ready for use on Sapelo2.

So, we have the last two dependencies to handle: snakemake-profiles and MiniIO Client

As for MiniIO Client, you can download and install it in your home dir on Sapelo2, following the instructions given at https://min.io/docs/minio/linux/reference/minio-mc.html :

64-bit Intel:
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help  (type "q" to quite_from Zhuofei)
mc -v

As for snakemake-profiles, I think it is optional and you can run the wags pipeline without it (by not using the wags' --profile option).


### Conda/Mamba is needed?

I have configured its environment for you on the cluster. What I did:

1. Using Mamba/23.1.0-4 to create a snakelike env (including pyyaml, wget, xlsxwriter etc. dependencies) at  
/home/ss11645/.conda/envs/snakemake/


2. Cleaned up your ~/.bashrc file:

I commented on two lines in your .bashrc. I put "# commented by ZH.2023.10.10" on the top of each line I commented out. The two lines that I commented on are not needed.

3. To enable wags pipeline scripts to use the snakemake env I created in step 1 above, I put a conda initialization block at the bottom of .bashrc. Its purpose is only for running the wag pipeline. You can permanently remove this block from your .bashrc file when you want to.

4. In your /scratch/ss11645/LC/SRA/prefetchData/sra/wags folder, I gave you a file called sourcrME. You will source this file before running pipeline scripts. I will give more details later, after you figured out how to set REF_GENOME (for --ref option) and RESULTS (for --bucket option).

The .basrc files is given by .basrc

FASTQ to GVCF (OneWAG)

The input file is given by input.csv

FASTQs located in /scratch/ss11645/LC/SRA/prefetchData/sra/download_data/

We ran prep_subs.py in cluster combining with bash script as slurm_generate.sh

The scripts will now generate separate pipelines with each pipelines can then be initiated with sbatch ShetlandSheepDog_ERR11203057.one_wag.slurm.




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
parallel-fastq-dump is a parallel wrapper of NCBI fastq-dump. It also has --gzip option:
https://github.com/rvalieris/parallel-fastq-dump
https://github.com/rvalieris/parallel-fastq-dump#micro-benchmark











