#!/bin/bash

update (){
	# save, clear screen
	tput smcup
	clear

	cd /home/$USER/.emacs.d/

	IFS=$'\n'
	for item in $package_list; do
		cd $item
		git pull
		cd ../.. # move back to /home/$USER/.emacs.d/
	done

	read -n1 -p "Press any key to continue..."
	# restore
	tput rmcup
}

init () {
	# git submodules are headless, this means that it is not possible to get the
	# current branches name one MUST checkout the branch before using this
	# script
	cd /home/$USER/.emacs.d/

	IFS=$'\n'
	for item in $package_list; do
		cd $item
		branch_name="$(git --no-pager branch -r | cut -d \/ -f 2 | grep 'main\|master' | head -n 1)"
		git checkout "$branch_name"
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

my_needed_commands="sregx"
missing_counter=0
for needed_command in $my_needed_commands; do
  if ! hash "$needed_command" >/dev/null 2>&1; then
    printf "Command not found in PATH: %s\n" "$needed_command" >&2
	case "$needed_command" in
		sregx)
			echo "Can be installed from this repo: https://github.com/zyedidia/sregx"
			;;
	esac
    ((missing_counter++))
  fi
done

if ((missing_counter > 0)); then
  printf "Minimum %d commands are missing in PATH, aborting\n" "$missing_counter" >&2
  exit 1
fi

package_list="$(sregx 'x/.*\n/ g/path/ x/[a-z]+\/[[:ascii:]]+\n/p' .gitmodules)"

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
				update
				;;
		esac
		shift
	done
else
	help_message
fi

exit 0
