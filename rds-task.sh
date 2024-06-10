#!/bin/bash

# Function to list all RDS
list_RDS() {
    aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier]' --output text
}

# Function to check the status of an RDS
RDS_status() {
    status=$(aws rds describe-db-instances --db-instance-identifier $1 --query 'DBInstances[*].[DBInstanceStatus]' --output text)
    if [ "$status" = "available" ]; then
        return 0
    else
        return 1
    fi
}

# Function to stop an RDS
stop_RDS() {
    aws rds stop-db-instance --db-instance-identifier $1 | tail -1
    echo "RDS instance $1 has been stopped."
}

# Function to start an RDS
start_RDS() {
    aws rds start-db-instance --db-instance-identifier $1 | tail -1
    echo "RDS instance $1 has been started."
}


# AWS Credentials
read -p "Enter your Project name: " Project_name
read -p "For $Project_name project access key ID: " aws_access_key_id
read -p "For $Project_name project secret access key: " aws_secret_access_key
read -p "For $Project_name preferred AWS region: " aws_region


profile_name="$Project_name"

# Configure AWS CLI with user input
aws configure set aws_access_key_id $aws_access_key_id --profile $profile_name
aws configure set aws_secret_access_key $aws_secret_access_key --profile $profile_name
aws configure set region $aws_region --profile $profile_name

# Main script

# List all RDS
echo "List of all RDS instances:"
list_RDS

# selecting an RDS instance
read -p "Enter the name of the RDS instance you want to select: " rds_name

# Input (start or stop)
read -p "Do you want to start or stop this RDS instance? ('$rds_name') [start/stop]: " action

case "$action" in
    "start")
        if RDS_status $rds_name; then
            echo -e "\033[1;32mCluster is already Started.\033[0m"
        else
            start_RDS $rds_name
        fi
        ;;
    "stop")
        if RDS_status $rds_name; then
            stop_RDS $rds_name
        else
            echo -e "\033[31mCluster is already Stoped.\033[0m"
        fi
        ;;
    *)
        echo "Invalid option. Please enter 'start' or 'stop'."
        ;;
esac

