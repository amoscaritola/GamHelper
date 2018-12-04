#!/bin/sh

clear
echo "#############################################"
echo "Gam Helper Version 1.0"
echo "https://github.com/amoscaritola"
echo "For help please view the README"
echo "#############################################"
echo ""

#Prompt user to enter CSV file location and verify before continuing
VerifyCsv() {
	echo ""
		echo "Enter CSV file location"
		read csvFile

		userVerify=""

		while [[ $userVerify != "y" ]]; do
			deviceCount=$(cat $csvFile | wc -l | sed -e 's/^[ \t]*//')
			echo "This CSV file contains $deviceCount devices."
			echo "Is this correct? (y/n) press any other key to cancel"
				read userVerify
			if [ $userVerify ==  "y" ]; then
				clear
			elif [ $userVerify ==  "n" ]; then
				echo "Enter CSV file location"
				read csvFile
			else
				exit 0
			fi
		done
}

# Function to exit out of script
ContinueOrExit() {
	echo "Continue to main menu or exit?"
	echo "Enter c to continue or any other key to exit."
	read continueExitResponse
	
	if [[ "$continueExitResponse" != "c" ]]; then
		exit 0
	fi
}

# Function to print list of OU's to csv file, then open file
PrintOuList() {
	echo "[1] - Save list of Organization Units to csv on desktop"
	echo ""
	gam print orgs | awk -F, '{print $1 "," $3}' > ~/Desktop/gamHelper/Chromebook\ OU\ List.csv
	sleep 2
	echo ""
	echo "Opening CSV of org units"
	echo ""
	open ~/Desktop/gamHelper/Chromebook\ OU\ List.csv
	ContinueOrExit
}

# Function to move chromebooks to a different OU
MoveChromebooks() {
	echo "Option [2] - Batch move Chromebooks to an OU selected."
	echo ""
	echo "Enter destination OU"
	read ouDestination
	echo ""
	echo "Enter CSV file location"
	read csvFile
	deviceCount=$(cat $csvFile | wc -l | sed -e 's/^[ \t]*//')
	userVerify=""

	while [[ $userVerify != "y" ]]; do
		clear
		echo "Ou is $ouDestination"
		echo "CSV file is $csvFile and contains $deviceCount devices."
		echo ""
		echo "Is this correct? (y/n)"
		read userVerify
			
		if [ $userVerify ==  "y" ]; then
			gam csv "$csvFile" gam update cros query:id:~~serial~~ ou "$ouDestination" > ~/Desktop/gamHelper/ChromebookOutput.csv
			devicesMoved=$(cat ~/Desktop/gamHelper/ChromebookOutput.csv | grep "moving" | wc -l | sed -e 's/^[ \t]*//')
			echo ""
			echo "$devicesMoved device(s) moved to  $ouDestination."
			echo ""
			ContinueOrExit
		elif [ $userVerify ==  "n" ]; then
			echo "Enter destination OU"
			read ouDestination
			echo "Enter CSV file location"
			read csvFile
		else
			echo "Invalid response, returning to main menu"
			break
		fi
		
	done
}

# Function to batch update device info
UpdateDeviceInfo() {

	echo "[3] - Batch update info on chromebooks"
	echo ""
	echo "What information would you like to update?"
	echo ""
	echo "[1] - user"
	echo "[2] - assetid"
	echo "[3] - location"
	echo "[4] - notes"
	echo "[5] - All of the above"
	echo "" 
	read infoToUpdate
	
	if [[ "$infoToUpdate" != "1" && "$infoToUpdate" != "2" && "$infoToUpdate" != "3" && "$infoToUpdate" != "4" && "$infoToUpdate" != "5" ]]; then
		echo "Incorrect Response, exiting"
		sleep 2
		exit 0
	fi
	
	#Run function to enter/check CSV
	VerifyCsv
		
	if [[ "$infoToUpdate" == "1" ]]; then
		echo "Please make sure csv format is: | serial | user |"
		echo "Press any key to continue"
		read continueKey
		gam csv "$csvFile" gam update cros query:id:~~serial~~ user ~user
	elif [[ "$infoToUpdate" == "2" ]]; then
		echo "Please make sure csv format is: | serial | assetid |"
		echo "Press any key to continue"
		read continueKey
		gam csv "$csvFile" gam update cros query:id:~~serial~~ assetid ~assetid
	elif [[ "$infoToUpdate" == "3" ]]; then
		echo "Please make sure csv format is: | serial | location |"
		echo "Press any key to continue"
		read continueKey
		gam csv "$csvFile" gam update cros query:id:~~serial~~ location ~location
	elif [[ "$infoToUpdate" == "4" ]]; then
		echo "Please make sure csv format is: | serial | notes |"
		echo "Press any key to continue"
		read continueKey
		gam csv "$csvFile" gam update cros query:id:~~serial~~ notes ~notes
	elif [[ "$infoToUpdate" == "5" ]]; then	
		echo "Please make sure csv format is: | serial | user | assetid | location | notes |"
		echo "Press any key to continue"
		read continueKey
		gam csv "$csvFile" gam update cros query:id:~~serial~~ user ~user assetid ~assetid location ~location notes ~notes
	else
		echo "something went wrong"
	fi
	
	ContinueOrExit
}

DeprovisionDevice() {
	echo "[4] - Deprovision chromebooks"
	
	# Input CSV file location and verify
	VerifyCsv
	#Deprovision the chromebooks listed in the CSV file
	gam csv $csvFile gam update cros query:id:~~serial~~ action deprovision_same_model_replace acknowledge_device_touch_requirement
	
	ContinueOrExit

}

# Create gamHelper folder on desktop if it does not exist
if [ ! -d ~/Desktop/gamHelper ]; then
	echo "Creating gamHelper folder on desktop"
	echo ""
	mkdir ~/Desktop/gamHelper
fi

############## Menu Loop ##############

while [[ $userChoice != "5" ]]; do

	echo "Please choose an option by entering the number"
	echo "[1] - Save list of Organization Units to csv on desktop"
	echo "[2] - Batch move Chromebooks to an OU"
	echo "[3] - Batch update info on chromebooks"
	echo "[4] - Deprovision chromebooks"
	echo "[5] - Exit"

	read userChoice

	if [ $userChoice == "1" ]; then
		clear
		PrintOuList
		clear
	elif [ $userChoice == "2" ]; then
		clear
		MoveChromebooks
		clear
	elif [ $userChoice == "3" ]; then
		clear
		UpdateDeviceInfo
		clear
	elif [ $userChoice == "4" ]; then
		DeprovisionDevice
		clear
	elif [ $userChoice == "5" ]; then
		echo "Exiting Script"
		exit 0
	else 
		echo "Invalid Response"
		sleep 2
		clear
	fi
		
done
exit 0