#!/bin/bash

# send bounces to:
MAIL_ADDRESSES="newsletter"
OPENEMM_URL="http://$OPENEMM_HOST:$OPENEMM_PORT"

export OPENEMM_PORT OPENEMM_HOST MYSQL_HOST MAIL_ADDRESSES OPENEMM_URL

#set -m
#set -e

if ! [ -f /home/openemm/.CONFIGURED ]; then
	if [ -z "$OPENEMM_HOST" ] || [ -z "$OPENEMM_PORT" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASS" ] || [ -z "$MYSQL_HOST" ] || [ -z "$MYSQL_DB" ] || [ -z "$SMTP_HOST" ]; then
	        echo See http://github.com/lgibelli/docker-openemm/ for usage instructions.
        	exit
	fi
	mkdir -p /home/openemm
	cp -a /home/openemm-orig/. /home/openemm/.
	/setup-openemm.sh
	chown -R openemm /home/openemm
	touch .CONFIGURED
fi

echo "" >/home/openemm/conf/bav/bav.conf-local
COUNTER="1"
for ADDRESS in $MAIL_ADDRESSES; do
	echo "${ADDRESS}@${OPENEMM_HOST} alias:ext_${COUNTER}@${OPENEMM_HOST}" >> /home/openemm/conf/bav/bav.conf-local
	COUNTER=$[$COUNTER+1]
done

touch /var/log/maillog && chown openemm /var/log/maillog

echo Starting OpenEMM...

su openemm -c 'sh /home/openemm/bin/openemm.sh start'
tail -f /home/openemm/logs/* /home/openemm/var/log/*
echo Attempting a clean shutdown...
su openemm -c 'sh /home/openemm/bin/openemm.sh stop'
