#!/bin/bash
source ./common.sh
app_name="payment"

checkroot
app_setup
python_setup
service_setup
print_total_time