install_mysql()
{
	echo
	echo
	echo "#########################################################"
	echo "############# Installing Mysql server ################"
	echo "#########################################################"
	echo
	echo
	sudo apt-get update && sudo apt-get install mysql-server -y
	sudo mysql -u root -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"
}

install_php()
{

	version=$1
	echo "Installing php"
	echo -ne '\n' | sudo add-apt-repository ppa:ondrej/php && sudo apt-get update

	echo "Installing php extensions"
	sudo apt-get install php$version php$version-cli php$version-common php$version-json php$version-mysql php$version-mbstring php$version-zip php$version-fpm php$version-zip php$version-xml php$version-gd php$version-curl -y

}

########### Defualt php version ###########
defaultPHP=7.2

read -p "Do you want to install chrome ? : " chrome
if [ "$chrome" == "y" ] || [ "$chrome" == "Y" ] ; then

	echo
	echo
	echo "#########################################################"
	echo "################## Install chrome in ubuntu #############"
	echo "#########################################################"
	echo
	echo
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
	sudo apt-get update
	sudo apt-get install google-chrome-stable -y
fi

echo
echo
echo "#########################################################"
echo "#### Running apt-get update and apt-get upgrade #########"
echo "#########################################################"
echo
echo
sudo apt-get update && apt-get upgrade
echo
	echo "Which Web Server Do you want?"
	echo "   1) Apache with php7.2"
	echo "   2) NGNIX with php7.2-fpm"
	read -p "Select an option: " option
	until [[ "$option" =~ ^[1-2]$ ]]; do
			echo "$option: invalid selection."
			read -p "Select an option: " option
		done
	case "$option" in
		1)
		echo
		echo
		echo "#########################################################"
		echo "############# Installing Apache2 with php ###############"
		echo "#########################################################"
		echo
		echo
		sudo apt-get install apache2 -y
		# echo "Apache2 installed successfully"
		# sudo service apache2 status -q

		echo "Running libapache2-mod-php"
		sudo apt-get install libapache2-mod-php

		sudo chmod -R 777 /var/www/html


		install_mysql

		;;
		2) 
		echo "NGNIX"


		echo
		echo
		echo "#########################################################"
		echo "########### Installing Nginx with php7.2-fmp ############"
		echo "#########################################################"
		echo
		echo

		sudo apt-get install nginx -y

		install_php $defaultPHP

		#echo "alias php=/usr/bin/php$defaultPHP" >> ~/.bashrc
		sudo update-alternatives --config php

		#bash

		sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/$defaultPHP/fpm/php.ini
		sudo systemctl restart php$defaultPHP-fpm
		sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/old_default

		defaultNGinxConf=~/Documents/default
		touch $defaultNGinxConf

		echo "server {" >> $defaultNGinxConf
		echo "    listen 80 default_server;" >> $defaultNGinxConf
		echo "    listen [::]:80 default_server;" >> $defaultNGinxConf
		echo "" >> $defaultNGinxConf
		echo "    root /var/www/html;" >> $defaultNGinxConf
		echo "    index index.php index.html index.htm index.nginx-debian.html;" >> $defaultNGinxConf
		echo "" >> $defaultNGinxConf
		echo "    server_name _;" >> $defaultNGinxConf
		echo "" >> $defaultNGinxConf
		echo "    location / {" >> $defaultNGinxConf
		echo "        try_files $uri $uri/ =404;" >> $defaultNGinxConf
		echo "    }" >> $defaultNGinxConf
		echo "" >> $defaultNGinxConf
		echo "    location ~ \.php$ {" >> $defaultNGinxConf
		echo "        include snippets/fastcgi-php.conf;" >> $defaultNGinxConf
		echo "        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;" >> $defaultNGinxConf
		echo "    }" >> $defaultNGinxConf
		echo "" >> $defaultNGinxConf
		echo "    location ~ /\.ht {" >> $defaultNGinxConf
		echo "        deny all;" >> $defaultNGinxConf
		echo "    }" >> $defaultNGinxConf
		echo "}" >> $defaultNGinxConf


		sudo mv $defaultNGinxConf /etc/nginx/sites-available/default

		;;
	esac

	echo
	echo
	echo "#########################################################"
	echo "############# Installing Nodejs with npm ################"
	echo "#########################################################"
	echo
	echo
	sudo apt-get install curl -y
	echo
	echo "Which Node version Do you want?"
	read -p "Select an option: (default Node version is 12) : " $nodeVersion
	if [ -z "$nodeVersion" ]
	then
		nodeVersion=12;
      	echo "Installing node $nodeVersion"
      	echo "https://deb.nodesource.com/setup_$nodeVersion.x"
    fi
	curl -sL https://deb.nodesource.com/setup_$nodeVersion.x | sudo -E bash -
	sudo apt-get install nodejs -y

	echo
	echo
	echo "#########################################################"
	echo "######### Installing composer with laravel ##############"
	echo "#########################################################"
	echo
	echo
	sudo apt-get install composer -y
	composer global require laravel/installer
	echo 'export PATH=$PATH:~/.config/composer/vendor/bin' >> ~/.bashrc
	export PATH=$PATH:~/.config/composer/vendor/bin
	#bash

	read -p "You want to install valet ? Press y to install : " valetOption

	if [ "$option" = '2' ] ; then

		echo
		echo
		echo "#########################################################"
		echo "################ Installing Linux-Valet #################"
		echo "#########################################################"
		echo
		echo
		if [ "$valetOption" == "y" ] || [ "$valetOption" == "Y" ] ; then
			
			sudo apt-get install network-manager libnss3-tools jq xsel -y

			composer global require cpriego/valet-linux
			export PATH=$PATH:~/.config/composer/vendor/bin

			valet install

			nameservers=~/Documents/custom-nameservers
			touch $nameservers

			echo "nameserver 0.0.0.0" >> $nameservers
			sudo mv $nameservers /opt/valet-linux/custom-nameservers
		fi
	fi

	bash


