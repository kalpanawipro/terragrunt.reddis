#!/bin/bash

#Create folder for git file changes track
dir=$1
pat=$2

rm -fr gitFiles
mkdir gitFiles

if [ -z $dir ]; then

    # wget https://github.com/cli/cli/releases/download/v2.30.0/gh_2.30.0_linux_amd64.tar.gz -qO github.tar.gz
    # tar -xzf github.tar.gz
    # chmod +x ./gh_2.30.0_linux_amd64/bin/gh
    if [ -z $CHANGE_ID ]; then
        prNumber=$(curl "http://52.222.34.71:8081/api/v4/projects/4/merge_requests?state=merged&access_token=$pat" | jq .[0].iid)
    else
        prNumber=${CHANGE_ID} ##
    fi
##
    filesChanged=$(curl "http://52.222.34.71:8081/api/v4/projects/4/merge_requests/$prNumber/changes?access_token=$pat" | jq .changes[].new_path)

    # Store the modiled files in live folder and affected environments in local files
    echo "$filesChanged" | while IFS= read -r line; do
        if [[ $line == *live* ]]; then
            echo $line >>gitFiles/liveDirChanged.txt
            echo $line | cut -d '/' -f2 >>gitFiles/envChanged.txt
        else
            echo $line >>gitFiles/otherDirChanged.txt
        fi
    done

    # Check if multiple environments were affected in the MR
    if [ -f "gitFiles/liveDirChanged.txt" ]; then
        uniqueENV=$(cat gitFiles/envChanged.txt | cut -d ' ' -f 1 | sort -u | uniq | wc -l)

        if [ $uniqueENV -gt 1 ]; then
            echo "More than 1 environment changed in the PR; Aborting the pipeline execution; Please follow correct workflow"
            exit 255
        fi
        #Affected environment
        environment=$(cat gitFiles/envChanged.txt | cut -d ' ' -f 1 | sort -u)

        # Store the affected files in the env in a local file
        cat gitFiles/liveDirChanged.txt | while IFS= read -r line; do
            if [[ $line =~ "$environment" && $line =~ "core-app-infra" ]]; then
                dir=$(dirname $line)
                echo ${dir%/configs*} >>gitFiles/fileChangedInEnvNonUnique.txt
            fi
        done

        cat gitFiles/fileChangedInEnvNonUnique.txt | uniq >>gitFiles/fileChangedInEnv.txt
        cat gitFiles/fileChangedInEnv.txt
    else
        touch gitFiles/fileChangedInEnv.txt
    fi
else
    echo $dir > gitFiles/fileChangedInEnv.txt
fi
