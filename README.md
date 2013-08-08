Raspberry-PI-Webcamscript
=========================

Raspberry-PI-Webcamscript

#1. What it does: 
	The webcam script is designed to take a photo, make thumbnails, add a logo and put it on a webserver via lftp.
	additionally it adjusts the iso parameter from camera at night. it runs takes as many photos as possible. 
	

#2. Todo 
###First of all please Install the Newest Firmware of the Raspary pi. Execute this:

	sudo apt-get update
	sudo apt-get upgrade
	sudo rpi-update
	
	

=> after installation please Reboot

###you must be shure, the Camera is switched to enabled in 

	sudo raspi-config
	
###set your timezone with

	sudo dpkg-reconfigure tzdata

###We need to install some Things like ImageMagick, lftp and other stuff. So we need to execute:

	sudo aptitude install imagemagick lftp sed at 

###if you want the automatic iso Change you also need the tool "SUN" - you will get it from the steffenvogel.de homepage
> LINK :  https://github.com/stv0g/sun  

Please Build and compile it (i don't explain it here ;)

###now we need to download the webcam.sh script and place it into a Directory witch fits. in this case i use the /usr/bin/

#### make the file executable
	chmod +x /usr/bin/webcam.sh

and use your favourite Editor to adjust the Parameters

The Parameters are:
		
	WebcamPicture=/tmp/webcam.jpg								# where to place the original webcam picture
	LogoPicture1=/home/pi/logo.png								# a logo-file for the full size picture
	LogoPicture2=/home/pi/logo.png								# a logo-file for the thumbnail size picture
	WorkPicture=/tmp/webcam_tmp.jpg								# a workfile to prevent the original from editing 
	WorkPictureThumbnail=/tmp/webcam_thumb.jpg					# a workfile for the thumpnail 
	LOGFILE=/var/log/webcam.sh.log								# a logfile
	ISOFILE=/etc/isowert										# the "iso" Parameter of the camera (and more)
	RASPISTILLPARAM=" -n -e jpg -q 100 "						# default parameters for the raspistill command 
	THUMPPARAM=" -resize 640x480 -type Optimize -quality 100 "	# Thumbnail Parameters 
	WEBSERVERFILE1="webcam.jpg"									# how the file on web/ftp server is named
	WEBSERVERFILE2="webcam_thumb.jpg"							# how the thumbnailfile on web/ftp server is named
	PIDFILE=/tmp/webcam.running									# just a pid file

	FTPServer=""												# ftp-server
	FTPUser=""													# ftp-user
	FTPPass=""													# ftp-password 
	FTPPATH="/"													#  path at the ftp server 
	
### Now we must add some entrys at the Crontable in order to run the script automatic. i desided to start the script every minute. but it doesnt matter. because if the script iss running, it aborts automaticly.
#### Edit the file /etc/crontab with your favorite editor and add the following lines

	* * * * *       root    /usr/bin/webcam.sh
	5 0     * * * root      echo 'echo "800 -ex auto " >/etc/isowert' | at $(sun rise -q Heilbronn -t civil )
	0 14    * * * root      echo 'echo "4000 -ex night " >/etc/isowert' | at $(sun set -q Heilbronn -t astro )
	0 10     * * * root      echo "200 -ex auto " >/etc/isowert
	
##### Let me explain.

###### Lets get sure , the webcam.sh file is always running. 
	* * * * *       root    /usr/bin/webcam.sh 
##### We want , after the sunrise to lower the iso parameter and switch the mode to automatic mode. So at 00:05 it checks the time for the sunrise and the location. 
	5 0     * * * root      echo 'echo "800 -ex auto " >/etc/isowert' | at $(sun rise -q Heilbronn -t civil )
##### At afternoon at 2 pm it checks, when the sunset hits the city and switch to an incredably high iso parameter. :) 
	0 14    * * * root      echo 'echo "4000 -ex night " >/etc/isowert' | at $(sun set -q Heilbronn -t astro )
##### at 10am set the "normal" iso parameter. in our region  the sunrise is never later than that.

so. almost done.

#3. Forecast
i want to add a temperature into the picture and some other text. it would be done soon :)

any suggestions ? please send me an e-mail tkloppholz <@> web.de

greetings from earth

