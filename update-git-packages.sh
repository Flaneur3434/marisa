#!/bin/bash

# !!! Warning This Script relies on sregx (https://github.com/zyedidia/sregx)
package_list="$(sregx 'x/.*\n/ g/path/ x/[a-z]+\/[[:ascii:]]+\n/p' .gitmodules)"

update (){
	cd /home/$USER/.emacs.d/

	IFS=$'\n'
	for item in $package_list; do
		cd $item
		git pull
		cd ../.. # move back to /home/$USER/.emacs.d/
	done
}

init () {
	# git submodules are headless, this means that it is not possible to get the
	# current branches name one MUST checkout the branch before using this
	# script
	cd /home/$USER/.emacs.d/

	IFS=$'\n'
	for item in $package_list; do
		cd $item
		echo $item
		branch_name="$(git --no-pager branch -r | cut -d '/' -f 2 | fzy -p 'Choose a branch: ')"
		git checkout $branch_name
		cd ../.. # move back to /home/$USER/.emacs.d/
	done
}

help_message (){
	cat <<EOF
USEAGE: update-git-packages.sh [OPTION]
  --help              Print help message
  --init              use this flag to set master/main branch in each submodule
  --update            git pull for each submodule
  no flags            Print help message
EOF
}

if [[ $# != 0 ]]; then
	while [[ ! $# == 0 ]]
	do
		case "$1" in
			--init)
				init
				;;
			--help)
				help_message
				;;
			--update)
				printf "updating submodules..\n\n\n"
				update
				;;
		esac
		shift
	done
else
	help_message
fi
