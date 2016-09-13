#! /usr/bin/zsh

base_dir=/var/cache/pacman
pkg_dir=$base_dir/pkg
repo=arch_desktop

current_db_packages=$(cat $base_dir/${repo}_packages_list)
pkg_packages=$(ls -1 $pkg_dir/*.pkg.tar.xz)
#aur_packages=$(ls -1 $aur_dir/*.pkg.tar.xz)

new_packages_list=$(echo -e "$current_db_packages\n$pkg_packages" | sort | uniq  -u)
new_packages=($(echo $new_packages_list | tr "\n" " "))

if [ ${#new_packages[@]} -le 0 ]; then
	echo -e "\nNo new packages were added to the repository db"
	exit
fi

echo -e "new packages: \n$new_packages_list"

echo -e $new_packages_list >> $base_dir/${repo}_packages_list
echo -e "\nAdding the new packages to the repository db"
repo-add $pkg_dir/$repo.db.tar.gz $new_packages

#TODO add bkp for the repo db
