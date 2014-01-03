#!bin/bash

#ynsetup.sh
# This will help to setup the yantranet-enabled device for use with the digital signage module

#Set the host name and change it in the SimpleGateway dir, too.
#Re-read the hostname and update the ENV settings.

# Write the script to do the setup.
# Use wget to get the string with appropriate arguments
# Ask Varma about the Simplegateway programmers options for writing the hostname to the file.
#

sed -i.bak '/<license_uuid>/c <license_uuid>' $license_key '</license_uuid>' install.xml