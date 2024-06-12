#!/bin/bash

action=$1
pwd=$2

command="terragrunt run-all $action -no-color"
changes=0

git config --global url."http://${GITLAB_TOKEN_USR}:${GITLAB_TOKEN_PSW}@${GH_INTERNAL_HOST}:8081".insteadof "http://${GH_INTERNAL_HOST}:8081"

while read -r line; do
    dir=$line
    dir="${dir#*/}"
    command="$command --terragrunt-include-dir $dir -no-color"
    changes=1
done < gitFiles/fileChangedInEnv.txt

command="$command --terragrunt-include-external-dependencies --terragrunt-non-interactive -no-color"

echo "Command: $command"

if [ $changes -eq 1 ]; then
    cd $pwd/live/
    export TF_CLI_ARGS_plan="-refresh=false"
    export TF_CLI_ARGS_apply="-refresh=false"
    eval $command
else
    echo "No directories changed"
fi