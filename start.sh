#!/usr/bin/env bash

# --------------Variable -------------- #

BOOTCLASSPATH=""
requirements="openjdk-6-jre java-common zip"

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
		else
			cout info "Cool, you have $package"
		fi
	done
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

trap control_c SIGINT
check_requirements
test_adb