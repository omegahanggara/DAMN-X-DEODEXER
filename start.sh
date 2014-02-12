#!/usr/bin/env bash

# --------------Variable -------------- #

BOOTCLASSPATH=""
requirements="java-common zip"
architecture=""

# FUNCTIONS ARE HERE

function control_c() {
	ask_to_quit="true"
	while [[ $ask_to_quit == "true" ]]; do
		cin warning "Are you sure you want to quit? (Y/n) "
		read answer_to_quit
		if [[ $answer_to_quit == *[Yy]* || $answer_to_quit == "" ]]; then
			cout info "NO! GUH!!!"
			ask_to_quit="false"
			exit $?
		elif [[ $answer_to_quit == *[Nn]* ]]; then
			cout info "ROCK ON!"
			ask_to_quit="false"
		else
			cout info "Try harder!"
		fi
	done
}

function cin() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "warning" ] ; then output="\e[01;31m[w]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[e]\e[00m" ; fi
	output="$output $2"
	echo -en "$output"
}
 
function cout() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "warning" ] ; then output="\e[01;31m[w]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[e]\e[00m" ; fi
	output="$output $2"
	echo -e "$output"
}

function check_requirements() {
	cout action "Checking requirements..."
	sleep 1
	for package in $requirements; do
		cout action "Checking $package"
		sleep 1
		if [[ $(dpkg -l | grep ii | grep $package) == "" ]]; then
			cout warning "Warning, $package has not installed yet"
			ask_to_install_package=true
			while [[ $ask_to_install_package == "true" ]]; do
				cin info "Do you want to install $package? (Y/n) "
				read answer_to_install_package
				if [[ $answer_to_install_package == *[Yy]* || $answer_to_install_package == "" ]]; then
					ask_to_install_package=false
					cout action "Will installing $package. This process need root access!"
					sleep 1
					ask_to_apt_get_update=true
					while [[ $ask_to_apt_get_update == "true" ]]; do
						cin info "Do you want to run sudo apt-get update first? (Y/n) "
						read answer_to_apt_get_update
						if [[ $answer_to_apt_get_update == *[Yy]* || $answer_to_apt_get_update == "" ]]; then
							ask_to_apt_get_update=false
							cout action "Running sudo apt-get update..."
							sleep 1
							sudo apt-get update
						elif [[ $answer_to_apt_get_update == *[Nn]* ]]; then
							ask_to_apt_get_update=false
							cout action "Skipping apt-get update"
							sleep 1
						else
							cout warning "Try harder!!!"
						fi
					done
					sudo apt-get install $package
				elif [[ $answer_to_install_package == *[Nn]* ]]; then
					ask_to_install_package=false
					cout warning "Insufficient dependencies... Will abort now!"
					sleep 1
					exit 1
				else
					cout warning "Try harder!!!"
				fi
			done
		else
			cout info "Cool, you have $package"
		fi
	done
	cout action "Searching any version of openjdk installed on your system..."
	sleep 1
	if [[ $(dpkg -l | grep ii | grep openjdk) == "" ]]; then
		cout warning "You don't have any version of openjdk installed on your system"
		cout action "Searching openjdk package on your repository..."
		sleep 1
		if [[ $(apt-cache search openjdk | grep openjdk | awk '{print $1}' | grep '\-jre$') == "" ]]; then
			cout warning "No any version of openjdk found in your repository."
			exit 1
		else
			cout info "Found $(apt-cache search openjdk | grep openjdk | awk '{print $1}' | grep '\-jre$' | tr '\n' ' ')in your repository"
			number_of_pkg=$(apt-cache search openjdk | grep openjdk | awk '{print $1}' | grep '\-jre$' | wc -l)
			for pkg in $(apt-cache search openjdk | grep openjdk | awk '{print $1}' | grep '\-jre$'); do
				echo $pkg >> /tmp/pkg.list
			done
			for (( i = 1; i <= $number_of_pkg; i++ )); do
				for pkg in $(apt-cache search openjdk | grep openjdk | awk '{print $1}' | grep '\-jre$'); do
					cin info "$number_of_pkg. $pkg (Type $number_of_pkg to install $pkg) "
					read chosen_number
					pkg_to_install=$(head -$chosen_number /tmp/pkg.list)
					cout action "Will install $pkg_to_install"
					sleep 1
					sudo apt-get install $pkg_to_install
					rm /tmp/pkg.list
				done
			done
		fi
	else
		jdk_version=$(dpkg -l | grep ii | grep openjdk | awk {'print $2'} | tr '\n' ' ')
		cout info "You have $jdk_version installed on your system"
	fi
}

function check_arch() {
	cout action "Checking architecture..."
	sleep 1
	if [[ $(uname -m | grep i386) == ""  ]]; then
		cout info "You are NOT using 32bit LINUX distro, adb might not working if you have not installed ia32libs yet."
		sleep 1
		cout action "Checking ia32-libs..."
		sleep 1
		ask_to_install_ia32libs=true
		while [[ $ask_to_install_ia32libs == "true" ]]; do
			if [[ $(dpkg -l | grep ii | grep ia32-libs) == "" ]]; then
				cin warning "You don't have ia32libs installed on your system! Do you want to install it? (Y/n) "
				read answer_to_install_ia32libs
				if [[ $answer_to_install_ia32libs == *[Yy]* || $answer_to_install_ia32libs == ""  ]]; then
					ask_to_install_ia32libs=false
					cout info "Will install ia32-libs..."
					cout action "Reading dpkg configuration..."
					if [[ $(dpkg --print-foreign-architectures | grep i386) == "" ]]; then
						cout warning "i386 architecture is not implemented yet!"
						ask_to_add_i386_arch=true
						while [[ $ask_to_add_i386_arch == "true" ]]; do
							cin info "Do you want to add i386 architecture to your dpkg foreign architecture? (Y/n) "
							read answer_to_add_i386_arch
							if [[ $answer_to_add_i386_arch == *[Yy]* || $answer_to_add_i386_arch == "" ]]; then
								ask_to_add_i386_arch=false
								cout action "Adding i386 architecture to your dpkg foreign architecture..."
								sleep 1
								sudo dpkg --add-architecture i386
								cout info "Done..."
							elif [[ $answer_to_add_i386_arch == *[Nn]* ]]; then
								ask_to_add_i386_arch=false
								cout warning "Insufficient requirements! Exiting!!!"
								sleep 1
								exit 1
							else
								cout warning "Try harder!!!"
							fi
						done
					fi
				elif [[ $answer_to_install_ia32libs == *[Nn]* ]]; then
					ask_to_install_ia32libs=false
					cout warning "Insufficient requirements! Exiting!!!"
					sleep 1
					exit 1
				else
					ask_to_install_ia32libs=false
					sudo apt-get install ia32-libs
				fi
			else
				ask_to_install_ia32libs=false
				cout info "Good, you have ia32-libs installed!"
			fi
		done
	else
		cout info "You are running 32bit LINUX distro. This mean, you don't have to install ia32-libs to make adb work!"
		sleep 1
	fi
}

function test_adb() {
	cout action "Testing adb..."
	ask_to_connect=true
	while [[ $ask_to_connect == "true" ]]; do
		cout info "Please connect your phone to your PC/LAPTOP. Make sure you have checked USB Debuging on Developer Options"
		cin info "Have you? (Y/n) "
		read answer_to_connect
		if [[ $answer_to_connect == *[Yy]* || $answer_to_connect == "" ]]; then
			cout action "Finding phone... If you see this more than 10 secs, please check your phone, and grant your LINUX to access adb by checking the confirmation dialog on your phone"
			sleep 1
			ask_to_connect=false
		elif [[ $answer_to_connect == *[Nn]* ]]; then
			cout info "It's OK. Take your time... I will ask this again in 5 secs..."
			sleep 5
		else
			echo warning "Try harder!!!"
		fi
	done
	sleep 1
	./binary/adb kill-server
	./binary/adb wait-for-device
	./binary/adb devices
}

function set_bootclasspath() {
	cout action "I will pull /init.rc from your phone to get BOOTCLASSPATH..."
	sleep 1
	./binary/adb kill-server
	./binary/adb pull /init.rc /pulled/init.rc
	cout action "Checking if init.rc has successfuly pulled without any problem"
	if [[ -f pulled/init.rc ]]; then
		cout info "init.rc has been pulled successfuly"
	else
		cout warning "init.rc has not been pulled successfuly."
		cout action "Quiting..."
		sleep 1
		exit 1
	fi
	cout action "Reading your init.rc..."
	if [[ $(grep BOOTCLASSPATH pulled/init.rc) == "" ]]; then
		cout warning "This init.rc provide no BOOTCLASSPATH"
		cout action "Quiting..."
		sleep 1
		exit 1
	else
		cout action "Setting BOOTCLASSPATH parameter..."
		BOOTCLASSPATH=$(grep BOOTCLASSPATH pulled/init.rc | awk '{print $3}')
		cout info "Done... Your BOOTCLASSPATH is $BOOTCLASSPATH"
	fi

}

trap control_c SIGINT
check_requirements
check_arch
test_adb
set_bootclasspath