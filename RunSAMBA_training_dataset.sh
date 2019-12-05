#!/usr/bin/env bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

#activate nextflow environment
. $BASEDIR/config/conda_envs/nextflow_env.sh

#set test directories
if [ ! -z $TMP ] 
then 
  sed -i 's|/PATH/TO/OUTDIR/$projectName|$TMP/output.test/$projectName|g' config/params.config
  mkdir -p $TMP/tax.databases.test/
  export tax_db_dir=$TMP/tax.databases.test
  sed -i "s|/PATH/TO/qiime2/2019.07/DATABASE|$TMP/tax.databases.test/DATABASE_silva_v132_99_16S.qza|g" config/params.config
  #nextflow temp directory
  export NXF_TEMP=$TMP
elif [ ! -z $SCRATCH ] 
then
  sed -i 's|/PATH/TO/OUTDIR/$projectName|$SCRATCH/output.test/$projectName|g' config/params.config
  mkdir -p $SCRATCH/tax.databases.test
  export tax_db_dir=$SCRATCH/tax.databases.test
  sed -i "s|/PATH/TO/qiime2/2019.07/DATABASE_silva_v132_99_16S.qza|$SCRATCH/tax.databases.test/DATABASE_silva_v132_99_16S.qza|g" config/params.config
  #nextflow temp directory
  export NXF_TEMP=$SCRATCH
else
  sed -i 's|/PATH/TO/OUTDIR/$projectName|${baseDir}/output.test/$projectName|g' config/params.config
  mkdir -p $BASEDIR/tax.databases.test
  export tax_db_dir=$BASEDIR/tax.databases.test
  sed -i "s|/PATH/TO/qiime2/2019.07/DATABASE_silva_v132_99_16S.qza|$BASEDIR/tax.databases.test/DATABASE_silva_v132_99_16S.qza|g" config/params.config
  #nextflow temp directory
  export NXF_TEMP=$BASEDIR
fi

#download taxonomic database
DB=$tax_db_dir/DATABASE_silva_v132_99_16S.qza
if [ -f "$DB" ]; then
    echo "$DB exist"
else
    wget ftp://ftp.ifremer.fr/ifremer/dataref/bioinfo/sebimer/sequence-set/qiime2/2019.07/DATABASE_silva_v132_99_16S.qza -O $tax_db_dir/DATABASE_silva_v132_99_16S.qza
fi

#run nextflow nextmb workflow ($1 is useful if you want to run resume)
nextflow -trace nextflow.executor run SAMBA.nf $1

#deactivate nextflow environment
. $BASEDIR/config/conda_envs/delenv.sh
