#!/bin/bash
source ./common.sh
app_name="user"

checkroot
app_setup
nodejs_setup
service_setup
print_total_time