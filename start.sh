#!/usr/bin/env bash

# --------------Variable -------------- #

bootclasspath="1"
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

trap control_c SIGINT
check_requirements