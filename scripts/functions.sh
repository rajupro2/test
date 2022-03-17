# Comment
function setUpSSH {
# The usage is simply: source $(dirname "$0")/functions.sh setUpSSH userName passPhrase emailId
if [ $# -ne 3 ] ; then
  echo "Usage: source $(dirname "$0")/functions.sh setUpSSH userName passPhrase emailId"
  exit 1
fi 
userName=$1
passPhrase=$2
emailId=$3
echo "Set up ssh key for user $userName"
#Set up ssh key for user
mkdir -p /home/$userName/.ssh/  
[ -f /home/$userName/.ssh/id_ed25519 ] && mv -f /home/$userName/.ssh/id_ed25519 /home/$userName/.ssh/id_ed25519.old  
[ -f /home/$userName/.ssh/id_ed25519.pub ] && mv -f /home/$userName/.ssh/id_ed25519.pub /home/$userName/.ssh/id_ed25519.pub.old  
ssh-keygen -q -t ed25519 -f /home/$userName/.ssh/id_ed25519 -N $passPhrase -C $emailId
chown -R ${userName} /home/$userName/.ssh
echo $passPhrase > /home/$userName/.ssh/pp
chown ${userName} /home/$userName/.ssh/pp
chmod 400 /home/$userName/.ssh/pp
}

function uploadSSHKeyToGitHub {
# The usage is simply: source $(dirname "$0")/functions.sh uploadSSHKeyToGitHub userName targetAccessToken
if [ $# -ne 3 ] ; then
  echo "Usage: source $(dirname "$0")/functions.sh uploadSSHKeyToGitHub userName targetAccessToken collabFlag"
  exit 1
fi 
	echo $targetAccessToken
	SSH_KEY=/home/$userName/.ssh/id_ed25519
	#curl -H "Authorization: token $targetAccessToken" https://api.github.com/user/keys | jq '.[].title'
	for titleKeyId in $(curl -H "Authorization: token $targetAccessToken" https://api.github.com/user/keys | jq -r ".[] | [.title, .id] | @csv")
		do
		title=$(awk -F\, '{ print $1 }' <<< "$titleKeyId")
		keyId=$(awk -F\, '{ print $2 }' <<< "$titleKeyId")
		echo $title,$keyId "============================================================================="
		if [ $title == '"'$userName'"' ]
		then
			#curl -H "Authorization: token $targetAccessToken" https://api.github.com/user/keys | jq '.[].key_id'
			echo "Authorization: token $targetAccessToken" -X DELETE https://api.github.com/user/keys/$keyId
			curl -H "Authorization: token $targetAccessToken" -X DELETE https://api.github.com/user/keys/$keyId
		fi
		done
		
	# Add SSH Key to GitHub			
	curl -H "Authorization: token $targetAccessToken" --data "{\"title\":\"$userName\",\"key\":\"$(cat $SSH_KEY.pub)\"}" https://api.github.com/user/keys	
	if [[ $collabFlag == 'Y' ]];
	then
		echo "Authorization: token $targetAccessToken" https://api.github.com/repos/$targetGitHubUserName/$targetRepositoryName/collaborators/$personalGitHubUserName -X PUT -d '{"permission":"'$targetRepositoryPermission'"}'
		curl -H "Authorization: token $targetAccessToken" https://api.github.com/repos/$targetGitHubUserName/$targetRepositoryName/collaborators/$personalGitHubUserName -X PUT -d '{"permission":"'$targetRepositoryPermission'"}'
	fi
}

function installIfNotInstalled {
    name=$1
	installParam1=$2
    dpkg -s $name &> /dev/null  
    if [ $? -ne 0 ]

        then
            echo "************* $name is not installed. Installing  $name.............................."  
            sudo apt-get update
            sudo apt-get install $name $installParam1
        else
            echo "************* $name is already installed."
    fi
}

