#!/bin/bash
source ${GUEST_HOME}/${PROJECT}/conf/${VM_USER}.properties
source /home/$VM_USER/${PROJECT}/scripts/functions.sh
echo "$VM_USER"
if [[ "$VM_USER" == "vagrant" ]]
then
	for i in "${createUsersList[@]}"
	do
		echo "$i"
		# echo "*************************************Create new user
		echo "*************************************Create new user"
		sudo adduser --disabled-password --gecos "" $i --home /home/$i
		
		# "*************************************Reuse .bashrc settings from vagrant user"
		echo "*************************************Reuse .bashrc settings from vagrant user"
		sudo cp -rf /home/vagrant/.bashrc /home/$i
		sudo chown $i /home/$i/.bashrc
	
		# echo "*************************************Add user to sudoers group"
		echo "*************************************Add user to sudoers group"
		
		#sudo usermod -a -G sudo $i
		sudo mkdir -p /etc/sudoers.d
		if [ ! -f /etc/sudoers.d/$i ]
		then
			touch /etc/sudoers.d/$i
			echo "$i  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$i
		else
			echo "$i  ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$i
		fi
		
		# Copy authorized_keys of vagrant to other users
		sudo mkdir -p /home/$i/.ssh/
		if [ ! -f /home/$i/.ssh/authorized_keys ]
		then
			touch /home/$i/.ssh/authorized_keys
			sudo cat ${GUEST_HOME}/.ssh/authorized_keys | sudo tee /home/$i/.ssh/authorized_keys
			sudo chown $i /home/$i/.ssh/authorized_keys
		else
			sudo cat ${GUEST_HOME}/.ssh/authorized_keys | sudo tee -a /home/$i/.ssh/authorized_keys
			sudo chown $i /home/$i/.ssh/authorized_keys
		fi
		
		# Copy scripts to other users
		mkdir -p /home/$i/${PROJECT}/scripts
		cp -rf ${GUEST_HOME}/${PROJECT}/scripts/* /home/$i/${PROJECT}/scripts/
		mkdir -p /home/$i/${PROJECT}/conf
		[ -f ${GUEST_HOME}/${PROJECT}/conf/$i.properties ] && cp -rf ${GUEST_HOME}/${PROJECT}/conf/$i.properties /home/$i/${PROJECT}/conf/
		
	done
	installIfNotInstalled "jq" "-y"
	installIfNotInstalled "meld" "-y"
	
	installIfNotInstalled "git-all" "-y"
	
	sudo snap install pycharm-community --classic
	installIfNotInstalled "software-properties-common" "-y"
	sudo add-apt-repository ppa:deadsnakes/ppa -y
	installIfNotInstalled "python3.9" "-y"
	
	setUpSSH $VM_USER $passPhrase $emailId
	uploadSSHKeyToGitHub $VM_USER $targetAccessToken $collabFlag

fi