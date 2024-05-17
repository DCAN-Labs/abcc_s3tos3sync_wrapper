 #!/bin/bash 

set +x 
# determine data directory, run folders, and run templates
data_dir="/tmp" # where to output data
data_bucket_input="s3://ABCD_year1" # bucket that BIDS data will be pulled from and processed outputs will be pushed to
data_bucket_output="s3://<TIMSBUCKET>"
subject_list="raes_sublist.csv"
run_folder=`pwd`

# note from Luci: I would recommend adding separate variables for subfolders in source and destination buckets. for example, for moving 
# year 1 BIDs niftis, the output under Tim's bucket should be organized like "s3://<TIMSBUCKET>/ABCD_year1/sorted"

sync_folder="${run_folder}/run_files.sync"
sync_template="template.sync"

email=`echo $USER@umn.edu`
group=`groups|cut -d" " -f1`

# if processing run folders (sMRI, fMRI,) exist delete them and recreate
if [ -d "${sync_folder}" ]; then
	rm -rf "${sync_folder}"
	mkdir "${sync_folder}"
else
	mkdir "${sync_folder}"
fi

# counter to create run numbers
k=0
while IFS=',' read -r subid sesid rest_of_line; do
	sed -e "s|SUBJECTID|${subid}|g" -e "s|SESID|${sesid}|g" -e "s|DATADIR|${data_dir}|g" -e "s|BUCKET_IN|${data_bucket_input}|g" -e "s|BUCKET_OUT|${data_bucket_output}|g" -e "s|RUNDIR|${run_folder}|g" ${run_folder}/${sync_template} > ${sync_folder}/run${k}
	k=$((k+1))
done < "$subject_list"

chmod 775 -R ${sync_folder}
