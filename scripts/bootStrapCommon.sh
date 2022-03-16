#!/bin/bash
source ${GUEST_HOME}/${PROJECT}/conf/${VM_USER}.properties

#Install Json Processor for processing GitHub Api JSON response
sudo apt-get install jq -y

#Set up ssh key for GitHub
mkdir -p ${GUEST_HOME}/.ssh/  
[ -f ${GUEST_HOME}/.ssh/id_ed25519 ] && mv -f ${GUEST_HOME}/.ssh/id_ed25519 ${GUEST_HOME}/.ssh/id_ed25519.old  
[ -f ${GUEST_HOME}/.ssh/id_ed25519.pub ] && mv -f ${GUEST_HOME}/.ssh/id_ed25519.pub ${GUEST_HOME}/.ssh/id_ed25519.pub.old  
ssh-keygen -q -t ed25519 -f ${GUEST_HOME}/.ssh/id_ed25519 -N $passPhrase -C $emailId
chown -R ${VM_USER} ${GUEST_HOME}/.ssh
echo $passPhrase > ${GUEST_HOME}/.ssh/pp
chown ${VM_USER} ${GUEST_HOME}/.ssh/pp
chmod 400 ${GUEST_HOME}/.ssh/pp


echo $targetAccessToken
SSH_KEY=${GUEST_HOME}/.ssh/id_ed25519
#curl -H "Authorization: token $targetAccessToken" https://api.github.com/user/keys | jq '.[].title'
for titleKeyId in $(curl -H "Authorization: token $targetAccessToken" https://api.github.com/user/keys | jq -r ".[] | [.title, .id] | @csv")
	do
	title=$(awk -F\, '{ print $1 }' <<< "$titleKeyId")
	keyId=$(awk -F\, '{ print $2 }' <<< "$titleKeyId")
	echo $title,$keyId "============================================================================="
	if [ $title == '"'$VM_USER'"' ]
	then
		#curl -H "Authorization: token $targetAccessToken" https://api.github.com/user/keys | jq '.[].key_id'
		echo "Authorization: token $targetAccessToken" -X DELETE https://api.github.com/user/keys/$keyId
		curl -H "Authorization: token $targetAccessToken" -X DELETE https://api.github.com/user/keys/$keyId
	fi
	done
	
# Add SSH Key to GitHub			
curl -H "Authorization: token $targetAccessToken" --data "{\"title\":\"$VM_USER\",\"key\":\"$(cat $SSH_KEY.pub)\"}" https://api.github.com/user/keys

if [[ $collabFlag == 'Y' ]];
then
	echo "Authorization: token $targetAccessToken" https://api.github.com/repos/$targetGitHubUserName/$targetRepositoryName/collaborators/$personalGitHubUserName -X PUT -d '{"permission":"'$targetRepositoryPermission'"}'
	curl -H "Authorization: token $targetAccessToken" https://api.github.com/repos/$targetGitHubUserName/$targetRepositoryName/collaborators/$personalGitHubUserName -X PUT -d '{"permission":"'$targetRepositoryPermission'"}'
fi



# Meld tool for code or text compare
#sudo apt-get install meld -y

#Install Git Client
# sudo apt-get update
# sudo apt-get install -y git-all
# git --version
	
#Install Json Processor for processing GitHub Api JSON response
# sudo apt-get install jq -y
	
#Set Up SSH
#[ -f ~/.ssh/id_rsa ] && mv -f ~/.ssh/id_rsa ~/.ssh/id_rsa.old
#[ -f ~/.ssh/id_rsa.pub ] && mv -f ~/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub.old

#Install Python 3.9
# sudo snap install pycharm-community --classic
# sudo apt install software-properties-common -y
# sudo add-apt-repository ppa:deadsnakes/ppa -y
# sudo apt install python3.9 -y
# python3 --version
	
#Install GitHub CLI API
# curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
# sudo apt update
# sudo apt install gh
	
	
