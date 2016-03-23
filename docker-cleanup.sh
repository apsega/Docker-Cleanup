#!/bin/bash

#Declare log filename and location
log=/tmp/docker_cleaner_$(date +"%m-%d-%y").log

#Get active container names
active=$(docker ps -a --format "{{.Names}}" --filter status=running)

#Get volumes names of active containers
active_volumes=$(docker inspect $active | grep "Source" | grep /var/lib/docker | awk -F '"'  '{print $4}' | awk -F '/' '{print $6}')

#Pass used and all directory names to arrays
read -a used_directories <<< $active_volumes
read -a all_directories <<< $(ls /var/lib/docker/volumes)

#Remove used directories from all directories array
for del in ${used_directories[@]}
do
   all_directories=(${all_directories[@]/$del})
done

if [ ${#all_directories[@]} -eq 0 ]; then
    echo "No volumes to delete."
else
    volume_number=${#all_directories[@]}
    echo "Deleting volumes..." | tee $log
    images_size=$(du -sch ${all_directories[@]} | tail -1 | awk '{print $1}')
    rm -rfv /var/lib/docker/volumes/${all_directories[@]} >> $log
    echo "Done. $volume_number deleted" | tee -a $log
    printf "\nDisk space has been freed up by $images_size"

fi

if [ $(docker images -f "dangling=true" -q | wc -l) -eq 0 ]; then
    echo "No unused images to delete."
else
    echo "Deleting unused images..."
    docker rmi $(docker images -f "dangling=true" -q) | tee -a $log
    echo "Done." | tee -a $log
fi
