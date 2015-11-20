#!/bin/bash 


EOPENEMM_URL=$(echo $OPENEMM_URL | sed -e 's/\//\\\//g' -e 's/\&/\\\&/g')
EOPENEMM_HOST=$(echo $OPENEMM_HOST | sed -e 's/\//\\\//g' -e 's/\&/\\\&/g')

echo "Configuring OpenEMM..."
cd /usr/share/doc/OpenEMM-2015

mysql -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $MYSQL_DB -e "UPDATE company_tbl SET rdir_domain='$OPENEMM_URL';"

pushd /home/openemm

sed -i "s/http:\/\/localhost:8080/$EOPENEMM_URL'/g" webapps/openemm/WEB-INF/classes/cms.properties
sed -i "s/http:\/\/localhost:8080/$EOPENEMM_URL'/g" webapps/openemm/WEB-INF/classes/emm.properties
sed -i "s/http:\/\/localhost:8080/$EOPENEMM_URL'/g" webapps/openemm-ws/WEB-INF/classes/emm.properties
sed -i "s/http:\/\/localhost:8080/$EOPENEMM_URL'/g" webapps/openemm-ws/WEB-INF/classes/emm-ws.properties
sed -i "s/system.mail.host=localhost/system.mail.host=$SMTP_HOST'/g" webapps/openemm/WEB-INF/classes/emm.properties

sed -i "s/url=\"jdbc:mysql:\/\/localhost\/openemm/url=\"jdbc:mysql:\/\/$MYSQL_HOST\/$MYSQL_DB/g" conf/context.xml
sed -i "s/username=\"agnitas\"/username=\"$MYSQL_USER\"/g" conf/context.xml
sed -i "s/password=\"openemm\"/password=\"$MYSQL_PASS\"/g" conf/context.xml

sed -i "s/smtp.starttls/#smtp.starttls/g" bin/scripts/semu.py
sed -i "s/smtp.ehlo/#smtp.ehlo/g" bin/scripts/semu.py

sed -i "s/'localhost', 'agnitas', 'openemm', 'openemm/'$MYSQL_HOST', '$MYSQL_USER', '$MYSQL_PASS', '$MYSQL_DB/g" bin/scripts/agn.py

su openemm -c 'sh -x /home/openemm/bin/sendmail-disable.sh'
echo "${SMTP_HOST}" > conf/smart-relay
popd


