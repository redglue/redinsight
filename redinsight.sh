#!/bin/bash
RED='\033[0;41;30m'
BLUE='\033[0;44;30m'
STD='\033[0;0;39m'

 ###### MODIFY ##############################################
export subscription_id="ff4c2ac5-d6cc-4aaf-b3f3-0660a6283505"
#get ID from:
#azure account list

export groupname="hdinsight-group"
export location="westeurope"
#  Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
export storagename="redinsighstr"

export clustername="redemo"
export clustertype="Hadoop"

export cluster_username="redglue"
export cluster_pass="b7360eL1"
export ssh_username="sshhadoop"
export ssh_password="b7360eL1"

#Available SKU Names: LRS/ZRS/GRS/RAGRS/PLRS
export skuname="LRS"

#########################################################


show_menus() {
	clear
echo "                   .___      .__            		"     
echo "_______   ____   __| _/ ____ |  |  __ __   ____   "
echo "\_  __ \_/ __ \ / __ | / ___\|  | |  |  \_/ __ \  "
echo " |  | \/\  ___// /_/ |/ /_/  >  |_|  |  /\  ___/  "
echo " |__|    \___  >____ |\___  /|____/____/  \___  > "
echo "            \/     \/_____/                  \/   "
echo ""
echo "***************************************************"
echo "HDInsight Hadoop cluster Provisioning - Internal tool"
echo "Version: 1.0"
echo "# Menu #"
echo "1. Login Azure (mandatory)"
echo "2. Create Azure HDInsight Hadoop Cluster"
echo "3. View Azure HDInsight Cluster Details"
echo "4. Show All HDInsight Clusters"
echo "5. Delete HDInsight Cluster"
echo "6. Exit"
echo "Note: The variables defined on the script will be applied to all commands"
}

command_exists () {
    type "$1" &> /dev/null ;
}



read_options(){
	local choice
	read -p "Enter choice [ 1 - 4] " choice
	case $choice in
		1) login_azure ;;
		2) create_hadoop_cluster ;;
		3) show_cluster_details ;;
        4) show_all ;;
		5) delete_cluster ;;
		6) exit 0;;
		*) echo -e "${RED}Not available option!${STD}" && sleep 2
	esac
}

login_azure() {
	echo -e "${BLUE}Check if Azure CLI exists on the system...${STD}"
	if command_exists azure ; then
    	echo "Azure CLI exists - All good!"
	else
		echo "Azure CLI does not exists - Please download here:"
		echo "* https://docs.microsoft.com/en-us/azure/xplat-cli-install *"
		echo "Exiting.."
		exit -1
	fi
	echo -e "${BLUE}Setting your subscription id...${STD}"
	azure account set $subscription_id
	echo -e "${BLUE}Login Process..${STD}"
	azure login
	read -p "Press ENTER key to finish"
}

create_hadoop_cluster() {
	echo -e "${BLUE} Starting HDInsight Hadoop cluster creation now..${STD}"
	echo "* Clustername: $clustername"
	echo "* Cluster Type: $clustertype"
	echo "* Groupname: $groupname"
	echo "* Location: $location"
	echo "* Storage Name Tier: $storagename"
	echo "* Subscription ID: $subscription_id"
	read -p "Press ENTER key to continue or CTRL+C to exit..."
	echo "Switching to Azure Resource Manager..."
	azure config mode arm
	echo "Creating resource group for HDInsight cluster and storage..."
	azure group create $groupname $location
	echo "Creating the storage account..."
	azure storage account create -g $groupname --sku-name $skuname -l $location --kind Storage $storagename
	echo "Getting storage keys..."
	key1="$(azure storage account keys list -g $groupname $storagename | grep key1 | awk '{print $3}')"
	echo "The following storage key will be used: $key1"
	echo "Creating the Hadoop cluster - Please be patient :-)"
	azure hdinsight cluster create -g $groupname -l $location -y Linux --clusterType $clustertype --defaultStorageAccountName $storagename.blob.core.windows.net --defaultStorageAccountKey $key1 --defaultStorageContainer $clustername --workerNodeCount 2 --userName $cluster_username --password $cluster_pass --sshUserName $ssh_username --sshPassword $ssh_password $clustername
	echo "Done"
	read -p "Press ENTER key to finish"
}

show_cluster_details() {
echo -e "${BLUE} Showing HDInsight Hadoop cluster details now...${STD}"
	azure hdinsight cluster show -g $groupname -s $subscription_id -c $clustername -v
	read -p "Press ENTER key to finish"

}

delete_cluster() {
echo -e "${RED} Starting HDInsight Hadoop cluster delete now...${STD} "
	echo "* Clustername: $clustername"
	echo "* Groupname: $groupname"
	echo "* Subscription ID $subscription_id"
	echo "Note: Cluster verification is not implemented yet"
	read -p "Press ENTER key to continue or CTRL+C to exit..."
	azure hdinsight cluster delete -g $groupname --clusterName $clustername -s $subscription_id
	read -p "Press ENTER key to finish"

}

show_all() {
echo -e "${BLUE} Showing all HDInsight clusters now...${STD}"
	azure hdinsight cluster list -v
    read -p "Press ENTER key to finish"

}

while true
do
	show_menus
	read_options
done



