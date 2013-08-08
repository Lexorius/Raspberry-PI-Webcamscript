#!/bin/bash

#### Variables 

WebcamPicture=/tmp/webcam.jpg
LogoPicture1=/home/pi/logo.png
LogoPicture2=/home/pi/logo.png
WorkPicture=/tmp/webcam_tmp.jpg
WorkPictureThumbnail=/tmp/webcam_thumb.jpg
LOGFILE=/var/log/webcam.sh.log
ISOFILE=/etc/isowert
RASPISTILLPARAM=" -n -e jpg -q 100 "
THUMPPARAM=" -resize 640x480 -type Optimize -quality 100 "
WEBSERVERFILE1="webcam.jpg"
WEBSERVERFILE2="webcam_thumb.jpg"
PIDFILE=/tmp/webcam.running

##### FTP Datas
FTPServer=""
FTPUser=""
FTPPass=""
FTPPATH="/"

#### dont change something unless u are know what you do 
if [ -f $PIDFILE ] ; then
	OLDPID=$(head -1 $PIDFILE)
else
	OLDPID="UNKNOWN"
fi

if [ $(pidof -x webcam.sh| wc -w) -gt 2 ]; then 
    echo "Script is running more than once. - OLD PID : $OLDPIDtouch "
    echo "Script is running more than once. - OLD PID : $OLDPIDtouch " >>$LOGFILE
	tail -n 50000 $LOGFILE >$LOGFILE 
    exit
fi
touch $PIDFILE
echo $$ >$PIDFILE

function take_picture()
{
	echo "take Photo" >>$LOGFILE
	if [ -f $ISOFILE ] ; then
		ISO=$(head -1 $ISOFILE )
	else
		ISO=400
	fi
	DATUM=$(date "+%d-%m-%Y %H:%M;%S")
	rm -f $WorkPicture 2>&1 >>$LOGFILE 
	rm -f $WebcamPicture 2>&1 >>$LOGFILE
	echo "Taking Photo $DATUM - with Parameter :  -o $WebcamPicture $RASPISTILLPARAM  -ISO $ISO" >>$LOGFILE
	raspistill  -o $WebcamPicture $RASPISTILLPARAM  -ISO $ISO 		>>$LOGFILE
	cp $WebcamPicture $WorkPicture 2>&1 >>$LOGFILE
}

function add_logo()
{
	echo "add logo $1 $2" >>$LOGFILE
	if [ -f $1 ]; then
		if [ -f $2 ]; then
			cp $2 /tmp/$2.orig 2>&1 >>$LOGFILE 
			composite -dissolve 40% -gravity NorthEast -quality 100 $1 $2.orig $2 >> $LOGFILE
			rm -f /tmp/$2.orig 2>&1 >>$LOGFILE 
		fi
	fi
}


function generate_thumbnail()
{
	echo "generate Thumbnail $1 $2" >>$LOGFILE
	if [ -f $1 ]; then
			convert $THUMPPARAM $1 $2
	fi
}


function upload_ftp()
{
	FTPCOMMAND="cd $FTPPATH "
	if [ -f $1 ] ; then
		
		cp $1 /tmp/$WEBSERVERFILE1.uploadtemp
		FTPCOMMAND="$FTPCOMMAND && put /tmp/$WEBSERVERFILE1.uploadtemp && mv $WEBSERVERFILE1.uploadtemp $WEBSERVERFILE1 "
	fi
	if [ -f $2 ] ; then
		cp $2 /tmp/$WEBSERVERFILE2.uploadtemp
		FTPCOMMAND="$FTPCOMMAND && put /tmp/$WEBSERVERFILE2.uploadtemp && mv $WEBSERVERFILE2.uploadtemp $WEBSERVERFILE2 "
	fi
	echo FTP PARAMETER $FTPCOMMAND >> $LOGFILE
	lftp $FTPServer -u "$FTPUser,$FTPPass" -e "$FTPCOMMAND && quit"
}


while :
do
		take_picture
		generate_thumbnail $WorkPicture $WorkPictureThumbnail
		# add_logo $LogoPicture1 $WorkPicture
		# add_logo $LogoPicture2 $WorkPictureThumbnail
		upload_ftp $WorkPicture $WorkPictureThumbnail
done

