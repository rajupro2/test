#!/bin/bash
VM_USER=$1
PROJECT=$2
RUN_PHASE=$3
[ -f /home/$VM_USER/${PROJECT}/conf/${VM_USER}.properties ] && source /home/$VM_USER/${PROJECT}/conf/${VM_USER}.properties
if [[ "VM_USER" == "vagrant" ]] || [ ! -f /home/$VM_USER/${PROJECT}/conf/${VM_USER}.properties ]
then
	:
else
	if [[ "$RUN_PHASE" == "setPasswordForUsers" ]]
	then
		# Change password for other users
		sudo chpasswd <<<"$VM_USER:$passWord"
	fi

	if [[ "$RUN_PHASE" == "setUpSSH" ]]
	then
		source /home/$VM_USER/${PROJECT}/scripts/functions.sh
		setUpSSH $VM_USER $passPhrase $emailId
		uploadSSHKeyToGitHub $VM_USER $targetAccessToken $collabFlag
	fi
fi

