@echo off

echo *** Framework for a multi development Environment
echo ***  1) Create a storage IN bucket


set PROJECT=shanemultidevenvironment
set ENVIRONMENTNAME=riskdev
set STORAGECLASS=Standard
set BELGIUM=europe-west1

call DateTime
echo *** setup all the variables
set INBUCKET=%PROJECT%-%ENVIRONMENTNAME%-in
set OUTBUCKET=%PROJECT%-%ENVIRONMENTNAME%-out
set LOGBUCKET=%PROJECT%-%ENVIRONMENTNAME%-logs
set ADVIEWER=ADGRP-%PROJECT%-viewer
set ADEDITOR=ADGRP-%PROJECT%-editor
set ADOWNER=ADGRP-%PROJECT%-owner
set ADEVIEWER=ADGRP-%PROJECT%-%ENVIRONMENTNAME%-viewer
set ADEEDITOR=ADGRP-%PROJECT%-%ENVIRONMENTNAME%-editor
set ADEOWNER=ADGRP-%PROJECT%-%ENVIRONMENTNAME%-owner
set VMNAME=%PROJECT%-%ENVIRONMENTNAME%-owner

echo INBUCKET=%PROJECT%-%ENVIRONMENTNAME%-in
echo OUTBUCKET=%PROJECT%-%ENVIRONMENTNAME%-out
echo LOGBUCKET=%PROJECT%-%ENVIRONMENTNAME%-logs
echo ADVIEWER=ADGRP-%PROJECT%-%ENVIRONMENTNAME%-viewer
echo ADEDITOR=ADGRP-%PROJECT%-%ENVIRONMENTNAME%-editor
echo ADOWNER=ADGRP-%PROJECT%-%ENVIRONMENTNAME%-owner

goto :EOF

call DateTime
echo *** list the configuration
call gcloud config list

call DateTime
echo *** create the new storage IN bucket (%BUCKET%)in Belgium
call gsutil mb -c %STORAGECLASS% -p %PROJECT% -l %BELGIUM% gs://%INBUCKET%

call DateTime
echo *** create the new storage IN bucket (%BUCKET%)in Belgium
call gsutil mb -c %STORAGECLASS% -p %PROJECT% -l %BELGIUM% gs://%OUTBUCKET%


call DateTime
echo *** create logging for bucket %INBUCKET%
call gsutil mb -c %STORAGECLASS% -p %PROJECT% -l %BELGIUM% gs://%LOGBUCKET%

call DateTime
echo *** grant access to %LOGBUCKET%
call gsutil acl ch -g cloud-storage-analytics@google.com:W gs://%LOGBUCKET%
call gsutil defacl set project-private gs://%LOGBUCKET%

call DateTime
echo *** set logging for %INBUCKET%
echo call gsutil logging set on -b gs://%LOGBUCKET% -o %ENVIRONMENTNAME%-log- gs://%INBUCKET%
call gsutil logging set on -b gs://%LOGBUCKET% -o %ENVIRONMENTNAME% gs://%INBUCKET%

call DateTime
echo *** set logging for %OUTBUCKET%
echo call gsutil logging set on -b gs://%LOGBUCKET% -o %ENVIRONMENTNAME%-log- gs://%OUTBUCKET%
call gsutil logging set on -b gs://%LOGBUCKET% -o %ENVIRONMENTNAME% gs://%OUTBUCKET%

call DateTime
echo *** get logging stats for buckets
call gsutil logging get gs://%INBUCKET%
call gsutil logging get gs://%OUTBUCKET%

rem give mr.shane.lamont.test1 write access to in bucket and outbucket
rem test 1
echo *** grant acl for buckets 1
call gsutil defacl ch -u mr.shane.lamont.test1@gmail.com:READ gs://%INBUCKET%
call gsutil acl ch -u mr.shane.lamont.test1@gmail.com:WRITE gs://%OUTBUCKET%

rem give mr.shane.lamont.test2 read access to outbucket only
echo *** grant acl for buckets 2
call gsutil defacl ch -u mr.shane.lamont.test2@gmail.com:READ gs://%OUTBUCKET%
rem give them both read access to log bucket *no write*


GOTO :EOF

call DateTime
echo *** create the IN bucket permissions
call gsutil mb -c Standard -p %PROJECT% -l europe-west1 gs://%BUCKET%


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


echo *** all finished
call DateTime


echo on





