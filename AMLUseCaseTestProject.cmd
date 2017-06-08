@echo off

echo *** Framework for the AML Use case
echo ***  1) Generate file with dummy customer transactions
echo ***  2) Create storage environment in Belgium and London
echo ***  3) Upload the dummy customer files
echo ***  4) Upload the dummy customer files but test zip
echo ***  5) Create a bigquery dataset and tables
echo ***  6) list the tables, information and contents
echo ***  7) run a query to get a few stats
echo ***  8) cleanup the buckets, tables and datasets

rem generate the 4 files file and upload
rem test with one file


rem needed for sequential calling
set gsutil="C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gsutil"
set gcloud="C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud"
set bq="C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\bq"
set PROJECT=amlusecasetestproject
set DATASET=%PROJECT%DataSet
set TABLE=CustomerTransactions
set SCHEMA=%TABLE%Schema.txt

call DateTime
echo *** Starting
python GenerateCustomerTransactions.py

call DateTime
echo *** list the configuration ( 5seconds)
call gcloud config list

call DateTime
echo *** create the new storage bucket (5 seconds) in Belgium
call gsutil mb -c Standard -p %PROJECT% -l europe-west1 gs://%PROJECT%-bucket-be/
call gsutil mb -c Standard -p %PROJECT% -l europe-west2 gs://%PROJECT%-bucket-gb/

call DateTime
echo *** verify that the bucket exists
call gsutil ls -p %PROJECT%

call DateTime
echo *** upload the customer file to google cloud
call gsutil cp custtxn.csv gs://%PROJECT%-bucket-be/custtxn.csv

call DateTime
echo *** upload the customer file to google cloud (zipped)
call gsutil cp -z csv custtxn.csv gs://%PROJECT%-bucket-be/custtxn.csv.gzip


call DateTime
echo *** list the files (show that it's there)
call gsutil ls -l gs://%PROJECT%-bucket-be/

call DateTime
echo *** setup a big query dataset
call bq mk %DATASET%

call DateTime
echo *** load the table (unzipped)
call bq load %DATASET%.%TABLE% gs://%PROJECT%-bucket-be/custtxn.csv ./%SCHEMA%

call DateTime
echo *** load the table (unzipped)
call bq load %DATASET%.%TABLE%FromZip gs://%PROJECT%-bucket-be/custtxn.csv.gzip ./%SCHEMA%

call DateTime
echo *** list the tables
call bq ls

call DateTime
echo *** get table information the tables
call bq show %PROJECT%:%DATASET%.%TABLE%

call DateTime
echo *** show first 10 rows
call bq head -n 10 %PROJECT%:%DATASET%.%TABLE%

call DateTime
echo *** run a query
type Test_AMLUseCaseTestProject.sql | bq query

echo *** finished

call DateTime
echo *** cleanup the bucket
call gsutil rm -r gs://%PROJECT%-bucket-be/
call gsutil rm -r gs://%PROJECT%-bucket-gb/

call DateTime
echo *** cleanup the BQ tables then BQ dataset
call bq rm -f %PROJECT%:%DATASET%.%TABLE%
call bq rm -f %PROJECT%:%DATASET%.%TABLE%FromZip
call bq rm -f %PROJECT%:%DATASET%

echo *** all finished
call DateTime


echo on





