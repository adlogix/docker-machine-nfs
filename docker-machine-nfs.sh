#!/bin/sh
#
# The MIT License (MIT)
# Copyright © 2015 Toni Van de Voorde <toni.vdv@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

set -o errexit

# BEGIN _functions

# @info:    Prints the usage
usage ()
{
  echo "usage: sh $0 <machine-name> [--force]"
  exit 0
}

# @info:    Prints error messages
# @args:    error-message
echoError ()
{
    echo "\033[0;31mFAIL\n\n$1 \033[0m"
}

# @info:    Prints warning messages
# @args:    warning-message
echoWarn ()
{
    echo "\033[0;33m$1 \033[0m"
}

# @info:    Prints success messages
# @args:    success-message
echoSuccess ()
{
    echo "\033[0;32m$1 \033[0m"
}

# @info:    Prints check messages
# @args:    success-message
echoInfo ()
{
    printf "\033[1;34m[INFO] \033[0m$1"
}

# @info:    Prints property messages
# @args:    property-message
echoProperties ()
{
    echo "\t\033[0;35m- $1 \033[0m"
}

# @info:    Checks if a given property is set
# @return:  true, if variable is not set; else false
isPropertyNotSet() 
{
    if [ -z ${1+x} ]; then return 0; else return 1; fi
}

# @info:    Checks if the machine is present
# @args:    machine-name
# @return:  (none)
checkMachinePresence ()
{
    echoInfo "machine presence ... \t\t\t"
    
    if [ "" = "$(docker-machine ls | sed 's/  */:/g' | grep $1:)" ]; then
        echoError "Could not find the machine '$1'!"; exit 1;
    fi
        
    echoSuccess "OK"
}

# @info:    Checks if the machine is running
# @args:    machine-name
# @return:  (none)
checkMachineRunning ()
{
    echoInfo "machine running ... \t\t\t"
    
    machine_state=$(docker-machine ls | sed 's/\*//g' | sed 's/  */:/g' | grep ^$1: | cut -d ':' -f3)
    
    if [ "Running" != "${machine_state}" ]; then
        echoError "The machine '$1' is not running but '${machine_state}'!"; exit 1;
    fi
    
    echoSuccess "OK"
}

# @info:    Loads mandatory properties from the docker machine
lookupMandatoryProperties () 
{
    echoInfo "Lookup mandatory properties ... \t\t"
    
    prop_machine_ip=$(docker-machine ip $1)
    
    prop_machine_vboxnet_name=$(VBoxManage showvminfo $1 --machinereadable | grep hostonlyadapter | cut -d'"' -f2)
    if [ "" = "${prop_machine_vboxnet_name}" ]; then
        echoError "Could not find the virtualbox net name!"; exit 1
    fi

    prop_machine_vboxnet_ip=$(VBoxManage list hostonlyifs | grep "${prop_machine_vboxnet_name}" -A 3 | grep IPAddress | cut -d ':' -f2 | xargs);
    if [ "" = "${prop_machine_vboxnet_ip}" ]; then
        echoError "Could not find the virtualbox net ip!"; exit 1
    fi
    
    echoSuccess "OK"
}

# @info:    Configures the NFS
configureNFS() 
{   
    echoInfo "Configure NFS ... \n"
    
    if isPropertyNotSet $prop_machine_ip; then echoError "'prop_machine_ip' not set!"; exit 1; fi
        
    echoWarn "\n !!! Sudo will be necessary for editing /etc/exports !!!"
    
    # Update the /etc/exports file and restart nfsd
    (
        echo '\n"/Users" '$prop_machine_ip' -alldirs -mapall='$(id -u)':'$(id -g)'\n' | sudo tee -a /etc/exports && \
        awk '!a[$0]++' /etc/exports | sudo tee /etc/exports
        
    ) > /dev/null
    
    sudo nfsd restart ; sleep 2 && sudo nfsd checkexports
    
    echoSuccess "\t\t\t\t\t\tOK"
}

# @info:    Configures the Boot2Docker to mount nfs
configureBoot2Docker()
{
    echoInfo "Configure Boot2Docker ... \t\t"

    if isPropertyNotSet $prop_machine_name; then echoError "'prop_machine_name' not set!"; exit 1; fi
    if isPropertyNotSet $prop_machine_vboxnet_ip; then echoError "'prop_machine_vboxnet_ip' not set!"; exit 1; fi

    # render bootlocal.sh and copy bootlocal.sh over to boot2docker
    # (this will override an existing /var/lib/boot2docker/bootlocal.sh)
    
    local bootlocalsh='#!/bin/sh
    sudo umount /Users
    sudo /usr/local/etc/init.d/nfs-client start
    sudo mount -t nfs -o noacl,async '$prop_machine_vboxnet_ip':/Users /Users'

    docker-machine ssh $prop_machine_name "echo '$bootlocalsh' | sudo tee /var/lib/boot2docker/bootlocal.sh && sudo chmod +x /var/lib/boot2docker/bootlocal.sh" > /dev/null
    
    echoSuccess "OK"
}

# @info:    Restarts Boot2Docker
restartBoot2Docker()
{
    echoInfo "Restart   Boot2Docker ... \t\t"
    
    if isPropertyNotSet $prop_machine_name; then echoError "'prop_machine_name' not set!"; exit 1; fi
    
    docker-machine restart $prop_machine_name > /dev/null
    
    echoSuccess "OK"
}

# @return:  'true', if NFS is mounted; else 'false'  
isNFSMounted()
{
    local nfs_mount=$(docker-machine ssh $prop_machine_name "df || true" | grep "$prop_machine_vboxnet_ip:/Users")
    if [ "" = "$nfs_mount" ]; then echo "false"; else echo "true"; fi
}

# @info:    Verifies that NFS is successfully mounted
verifyNFSMount()
{
    echoInfo "Verify NFS mount ... \t\t\t"
    
    if [ "$(isNFSMounted)" = "false" ]; then
        echoError "Cannot detect the NFS mount :("; exit 1
    fi
    
    echoSuccess "OK"
}

# @info:    Displays the finish message
showFinish()
{
    echo "\033[0;36m"
    echo "--------------------------------------------"
    echo 
    echo " The docker-machine '$prop_machine_name'"
    echo " is now mounted with NFS!"
    echo 
    echo " ENJOY high speed mounts :D"
    echo 
    echo "--------------------------------------------"
    echo "\033[0m"
}

# END _functions

[ "$#" -ge 1 ] || usage

prop_machine_name=$1
force_reconfiguration_nfs=$2

checkMachinePresence $prop_machine_name
checkMachineRunning $prop_machine_name

lookupMandatoryProperties $prop_machine_name

if [ "$(isNFSMounted)" = "true" ] && [ "$force_reconfiguration_nfs" = "" ]; then
    echoSuccess "\n NFS already mounted." ; showFinish ; exit 0
fi

echo #EMPTY LINE

echoProperties "Machine IP: $prop_machine_ip"
echoProperties "Machine VBOXNET name: $prop_machine_vboxnet_name"
echoProperties "Machine VBOXNET ip: $prop_machine_vboxnet_ip"

echo #EMPTY LINE

configureNFS

configureBoot2Docker
restartBoot2Docker

verifyNFSMount

showFinish
