#!/bin/bash
source ./common.sh
app_name="dispatch"

checkroot
app_setup
golang_setup
service_setup
print_total_time