#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


BUCKET=${BUCKET}
ARCHIVE=${ARCHIVE}
ADDON=${ADDON}
ENVIRONMENT=${ENVIRONMENT}

function check_previous_install () {
  if [ -x "$(command -v /opt/splunk/bin/splunk )" ]; then
  echo 'Info: splunk is installed.' >&2
  sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt
  exit 1
fi
}

function auto_format_secodary_disk () {
DEVICE_ID=$(sudo lsblk |tail -1 |awk '{print $1}')
TYPE=$(sudo file -sL /dev/$DEVICE_ID |awk '{print $2}')

if [ $TYPE = "data" ]; then
    sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DEVICE_ID
    sudo mkdir -p /opt/${ENVIRONMENT}
    echo UUID=`sudo blkid -s UUID -o value /dev/$DEVICE_ID` /opt/${ENVIRONMENT} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
    sudo mount --all
else
    echo "Disk already formatted skipping format commands"
    sudo mount --all
fi
}

function download_archive () {
#Download Package
gsutil cp gs://${BUCKET}/${ARCHIVE}	/tmp  
gsutil cp gs://${BUCKET}/${ADDON}	/tmp  
}

function unpack_archive () {
#Unzip Package
sudo tar -xf /tmp/${ARCHIVE} -C /opt/
}

function splunk_start () {
sudo cp /opt/splunk/etc/system/default/web.conf /opt/splunk/etc/system/local/web.conf
sudo sed -i 's/\$SPLUNK_HOME\///g' /opt/splunk/etc/system/local/web.conf
sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd $(hostname)
sudo /opt/splunk/bin/splunk install app /tmp/${ADDON} -auth admin:$(hostname)
sudo sed -i 's/enableSplunkWebSSL = false/enableSplunkWebSSL = true/g' /opt/splunk/etc/system/local/web.conf
sudo sed -i 's/httpport = 8000/httpport = 8080/g'  /opt/splunk/etc/system/local/web.conf
sleep 30
sudo reboot
}

check_previous_install
auto_format_secodary_disk
sleep 300
download_archive
unpack_archive
splunk_start
