#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

source_template_dir="$PWD/../"
source_dir="$source_template_dir/../source"

is_ami2=$(cat /etc/system-release 2> /dev/null | grep -oi Karoo)
if [ -z $is_ami2 ]; then
    echo "Not AMI2."
    read -p "Do you realy continue? (y/N): " yn
    case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac
fi

if !(type pip3 > /dev/null 2>&1); then
    echo "No pip3. Install python3."
    echo "exist!"
    exit
fi

echo "install boto3 --user"
pip3 install boto3 --user

echo "Install Node.js"
curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts node
nvm alias default lts/*
node -e "console.log('Running Node.js ' + process.version)"
echo "Install CDK"
npm install -g aws-cdk

cd ${source_dir}/cdk
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt

BACK=$RANDOM
if [ -e cdk.json ]; then
    mv cdk.json cdk.json.$BACK
fi

cp cdk.json.public.sample cdk.json
cdk synth aes-siem -o ${source_template_dir}/cdk-solution-helper/cdk.out 1>/dev/null

if [ -e cdk.json.$BACK ]; then
    mv -f cdk.json.$BACK cdk.json
fi
