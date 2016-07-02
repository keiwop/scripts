#! /usr/bin/zsh

#TODO Manage the deletion of files
#TODO Manage multiple input roots
#TODO Delete duplicates if wildcard result is in $in_files
#TODO Complete the wildcards recognized like ".Trash*"
#TODO Copy files also based on size
#TODO TODO Wildcard break on files with spaces
#TODO TODO Files are excluded recursively

in_root="/_" 
in_wildcards=("*.test" "*.bkp" "*.bak" "*~" "*.tar*" "*.gz" "*.bz*" "*.zip" "*.7z" "*.pyc" "*.bin" "*.elf" "*.hex" "*.scb" "*.o" "*.d" "*.ld" "*.lib" "*.ko" "*.jar" "*.class" "*.apk" "*.pkg" "*.exe" "*.jpg" "*.png" "*.gif" "*.rar" "*.img" "*.iso" "*.pdf" "*.do" "*.mp3" "*.ogg" "*.flac" "*.mkv" "*.webm" "*.mp4" "*.avi" "*.mpeg" "*.localstorage*" "*.kicad*" "*.fzz" "*.fex")
in_files=("abs" "bin" "bkp" "dev" "etc" "fun" "git" "img" "mnt" "net" "nfs" "opt" "src" "tmp" "usr")
#in_wildcards=("*.test")
#in_files=("test")

out_host="keiwop@192.168.1.4"
out_dir="/_/tmp"
out_path="${out_host}:${out_dir}"


#Exclude some files from being copied
exclude_files=("mnt/*" "net/torrent/*" "nfs/*" "tmp/*" "usr/VM/*" ".thumbnails/*" ".Trash-0/*" ".Trash-1000/*" ".git/*" "abs/test3/b.test" "app/build/*")

exclude_list=()
wild_exclude_list=()
for exclude_file in $exclude_files; do
	exclude_list=(${exclude_list} --exclude=${exclude_file})
	wild_exclude_list=(${wild_exclude_list} ! -path ${in_root}/${exclude_file})
done
echo "Exclude list: $exclude_list"
echo "Wildcard exclude list: $wild_exclude_list"


#Research the files containing the wildcard in their name
for wildcard in $in_wildcards; do
	echo "WILDCARD: $wildcard"
	IFS_orig=$IFS
	IFS=$'\n'
#	file_found=$(find "$in_root" -xdev -name "$wildcard" ${wild_exclude_list[@]})
#	wildcards_files_found=($wildcard_file_found "$file_found")
	wildcards_files_found=()
	find "$in_root" -xdev -name "$wildcard" ${wild_exclude_list[@]} | while read -r wildcard_file_found; do
#		echo "FILE: $wildcard_file_found"
		wildcards_files_found=(${wildcards_files_found} "$wildcard_file_found")
	done
#	wildcards_files_found=($(find "$in_root" -xdev -name "$wildcard" ${wild_exclude_list[@] -print0} | tr "\n" " "))
	IFS=$IFS_orig
	echo "found: $wildcards_files_found"

	for file_found in $wildcards_files_found; do
		echo "wildcard file: $file_found"
	#	Remove $in_root from the file path
		file_found=${file_found:$(( ${#in_root} + 1 ))}
		in_files=(${in_files} "$file_found")
	done
done
echo "input files: $in_files"


if [[ -d $1 ]]; then
	out_path="$1"
	out_root="$1"
	echo "Target directory exists: ${out_dir}"
else
	out_host=$(echo $1 | cut -d: -f1)
	out_dir=$(echo $1 | cut -d: -f2)
	out_root=$out_dir
	ssh -q $out_host "test -d $out_dir"
	if [[ $? -eq 0 ]]; then
		out_path="${out_host}:${out_dir}"
		echo "Target directory exists: ${out_path}"
	else
		echo "Target directory does not exists: $1"
		exit 1
	fi	
fi

echo ""

for in_file in $in_files; do
	in_path="${in_root}/${in_file}"
	
	if [[ -e "$in_path" ]]; then
		echo ""
#		echo "Input root: $in_root"		
		echo "Input file: $in_file"
#		echo "Output dir: $out_dir"
		echo "Output path: $out_path"
		echo -e "===\t${in_path} -> ${out_path}"

		rsync -HhAaxXvS --relative --progress ${exclude_list[@]} "${in_root}/./${in_file}" "${out_path}"
	fi
done
