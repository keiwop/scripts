#! /bin/sh

fedora_version=25

config_dnf(){
	echo -e "\n\nConfiguring the package manager\n"
	dnf -y update
	dnf -y install openssl

	dnf -y config-manager --add-repo http://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/Fedora_${fedora_version}/shells:zsh-users:zsh-completions.repo
	rpm --import 0xB91E1E8B
}

config_dnf


user="keiwop"
password="changemeplz"
password_cipher=$(echo $password | openssl passwd -1 -stdin)

user_groups="sys,lp,wheel,users,systemd-journal,mail,disk" #http,ftp
user_shell="zsh"

base_dir=$(pwd)

apps=(
	"zsh"
	"zsh-completions"
	"zsh-syntax-highlighting"
	"screen"
	"nano"
	"util-linux-user"
	"htop"
	"nmap"
	"python3"
	"python3-flask"
	"python3-scss"
	"python3-flask-sqlalchemy"
	
	# Dev tools for compiling OpenWRT/Lede
	binutils
	bison
	bzip2
	flex
	gawk
	gcc
	gcc-c++
	gettext
	git-core
	glibc
	glibc-devel
	glibc-headers
	glibc-static
	grep
	intltool
	make
	ncurses-compat-libs
	ncurses-devel
	openssl-devel
	patch
	perl-ExtUtils-MakeMaker
	perl-Thread-Queue
	quilt
	sdcc
	sed
	sharutils
	subversion 
	unzip
	wget
	zlib-devel
	zlib-static
)

ssh_key_laptop="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDI/DQxe2Fuv8hO1OQSK/9FPe7AvG9fj4ZlAB2QhP67TfG4s5JwoyFqZHWyItpuZculLiwXOoqKLexY1iFP6dSudzgAM0BmWbWvdTBjufYtszMlmm3eBN+XwXYvbvqMmxtnIKKEQaQHs25QwDAuCjU/7M+tkW185UCjRmr8wYArLGU90xvoxJhrohaPrdIn4zVdEdxlcDi3SdYB5osMoYdWNI8eC8XLTqWjXteeQqvXWXBBblBvihTkzqzoYLw7LOgSB71Y/k6SXxDpgko26tQND0NPxe5WCEVHmBddK8UeLXEeLCtQvlO8prabcxGK8PTGwsnE0/kCP3JO3z/4nkocLOSiRGMaJcynqPohBHLAoNM6qlBZZkW5O0go5xutF9oryiZH1lqevivayH0JSQ1ENmCGOn9gBfkbEKI2PUEixBOXCG6s0eousPCF1BkVnVD96ZClanG9RXyhmkDOcDsPdEIGx2B0DC4WdPCGLgw+ZiFpeUmLJd0vmouknnvya/3ey39wuQv/djFpDQpP29w49PxOM0Dydzel59mR+VmZMeUlMszMTkck6lRjhQDan5umggS0Fxrw44mqFSKaHTN/YYLn2img6jCznjGv3+/AndCjWjZ1GCBBGq780+xi/scwVxIEJaxHH2XHiViXyk78vgvasmwdNcpXFc+1k18fwQ== keiwop@arch_laptop"




install_apps(){
	echo -e "\n\nInstalling the applications\n"
	dnf -y install ${apps[@]}
}


create_user(){
	echo -e "\n\nCreating the user $user\n"
	shell_path=$(which $user_shell)
	useradd -m -d /home/$user -s $shell_path -p $password_cipher -G $user_groups $user
}


config_user(){
	echo -e "\n\nConfiguring the user $1\n"
	cd /tmp
	git clone https://github.com/keiwop/etc.git
	
	if [[ $1 = "$user" ]]; then
		home=/home/$user
	elif [[ $1 = "root" ]]; then
		home=/root
	else
		home=/tmp
	fi
	
	cp -v etc/zshrc $home/.zshrc
	cp -v etc/screenrc $home/.screenrc
	mkdir -p $home/.screenlogs
	
	mkdir -p $home/.ssh
	cat >> $home/.ssh/authorized_keys <<-EOF
	$ssh_key_laptop
	EOF
	
	if [[ $1 = "root" ]]; then
		sed -i "s:prompt_user_color=green:prompt_user_color=red:g" $home/.zshrc
		chsh -s $(which $user_shell)
	else
		chown $user.$user -R /home/$user
	fi
	
	# Fix the SELinux ACLs on the ssh authorized keys
	restorecon -R -v $home/.ssh
}


config_system(){
	echo -e "\n\nConfiguring the system\n"
	mkdir -p /_/dev /_/src /_/www
	chown -Rv $user.$user -R /_
	
	sed -i "s:PasswordAuthentication no:PasswordAuthentication yes:g" /etc/ssh/sshd_config
	
	chmod +w /etc/sudoers
	echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	chmod -w /etc/sudoers
	
	ln -svf /usr/share/zoneinfo/Europe/Paris /etc/localtime
}



# config_dnf
install_apps
create_user
config_user "root"
config_user "$user"
config_system

echo -e "\n\nThe configuration of the server is finished\n"
