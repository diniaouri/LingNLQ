#!/bin/bash
#SBATCH --time=12:00:00   # walltime
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8  # number of processor cores (i.e. threads)
#SBATCH -p gpu1,gpu2    # K80 GPUs on Haswell node
#SBATCH -J "fairseq_fconv"   # job name
#SBATCH -o "train_fairseq_fconv-%j.out"   # output name
#SBATCH --mem=20000   # minimum amount of real memory
#SBATCH -A p_adm # name of the project
#SBATCH --mail-user xiaoyu.yin@mailbox.tu-dresden.de
#SBATCH --mail-type ALL

# module load TensorFlow/1.8.0-foss-2018a-Python-3.6.4-CUDA-9.2.88

DDIR=data/monument_600
MDIR=output/models

if [ -n "$1" ]
    then DDIR=$1
fi

if [ -n "$2" ]
    then MDIR=$2
fi

# python3 preprocess.py -s en -t sparql --trainpref $DDIR/train --validpref $DDIR/dev --testpref $DDIR/test --destdir $DDIR/fairseq-data-bin

fairseq-train $DDIR/fairseq-data-bin -s en -t sparql \
--lr 0.5 --clip-norm 0.1 --dropout 0.2 --max-tokens 4000 \
--criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
--arch fconv_wmt_en_de --lr-scheduler fixed --force-anneal 50 \
--max-epoch 500 --save-interval 100 --valid-subset valid,test \
--optimizer nag \
--save-dir $MDIR/fairseq_fconv_wmt_en_de

