#!/bin/bash

# Clone the repository and navigate into it
git clone https://github.com/ovh/debian-cis.git && cd debian-cis

# Copy the default configuration file
cp debian/default /etc/default/cis-hardening

# Update the configuration file with the correct paths
sed -i "s#CIS_LIB_DIR=.*#CIS_LIB_DIR='$(pwd)'/lib#" /etc/default/cis-hardening
sed -i "s#CIS_CHECKS_DIR=.*#CIS_CHECKS_DIR='$(pwd)'/bin/hardening#" /etc/default/cis-hardening
sed -i "s#CIS_CONF_DIR=.*#CIS_CONF_DIR='$(pwd)'/etc#" /etc/default/cis-hardening
sed -i "s#CIS_TMP_DIR=.*#CIS_TMP_DIR='$(pwd)'/tmp#" /etc/default/cis-hardening

echo "CIS Hardening configuration updated successfully."
