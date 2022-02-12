#!/bin/bash

# !!! Warning This Script relies on sregx (https://github.com/zyedidia/sregx)
package_list="$(sregx 'x/.*\n/ g/^[[:blank:]]/ x/.*\n/ g/path/p' .gitmodules | cut -d ' ' -f 3)"

IFS=$'\n'
for item in $package_list; do
	cd $item
	git pull origin main
done
