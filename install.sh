#!/bin/bash  
# Copyright Mason Chase (mc@maxtld.com)
# DISCLAIMER: install.sh SCRIPT AND ITS CONTENT ARE DESIGNED AND TESTED UNDER CENTOS/FEDORA/REDHAT AND YOU MAY USE IT AT YOUR RISK ONLY.

# Download latest rpmforge to get 7zip in our system
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm -O /usr/src/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

# install yum reposity
rpm -ivh  rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm

# install 7zip with yum
yum install p7zip -y

# append some cron entry 
crontab -l | { cat; echo "
# Auto Update phpMyAdmin everyday at 4AM
0 4 * * * /usr/bin/phpmyadmin_update.sh"; } | crontab -

# 
cat >/usr/bin/phpmyadmin_auto_update.sh << EOL
#!/bin/bash  

# Copyright Mason Chase (sid@moontius.com)
# DISCLAIMER: install.sh SCRIPT AND ITS CONTENT ARE DESIGNED AND TESTED UNDER CENTOS/FEDORA/REDHAT AND YOU MAY USE IT AT YOUR RISK ONLY.

#echo on
set -x


# Must start and end with slash
PHPMYADMIN_FULL_PATH=/var/www/

# Must not contain slash
PHPMYADMIN_FOLDER_NAME=phpmyadmin

#  Download phpmyadmin download page
/usr/bin/wget https://www.phpmyadmin.net/downloads/ -O /tmp/phpmyadmin-download.html
# Map Latest phpmyadmin English with 7-zip format using regex
MYSQL_URL=\$(cat /tmp/phpmyadmin-download.html|grep -e "<a href=\"https://files.phpmyadmin.net/phpMyAdmin/4.[5-9].[0-9,\.]*/phpMyAdmin-4.*-english.tar.xz"|sed -n -e 's/.*<td><a href="\(.*\)" class=".*/\1/p')
echo \$MYSQL_URL
/usr/bin/wget \`echo \$MYSQL_URL\` -O /tmp/phpmyadmin.tar.xz
/usr/bin/tar -xJf /tmp/phpmyadmin.tar.xz -o\`echo \$PHPMYADMIN_FULL_PATH\`

# Move old php directory to a backup folder
mv \`echo \$PHPMYADMIN_FULL_PATH\`\`echo \$PHPMYADMIN_FOLDER_NAME\` \`echo \$PHPMYADMIN_FULL_PATH\`\`echo \$PHPMYADMIN_FOLDER_NAME\`_outdated

# Move new phpmyadmin to designated path and rename its folder name
mv \`echo \$PHPMYADMIN_FULL_PATH\`phpMyAdmin-*-english \`echo \$PHPMYADMIN_FULL_PATH\`\`echo \$PHPMYADMIN_FOLDER_NAME\`

# Move configuration file from old phpmyadmin to new installation
mv \`echo \$PHPMYADMIN_FULL_PATH\`\`echo \$PHPMYADMIN_FOLDER_NAME\`_outdated/config.inc.php \`echo \$PHPMYADMIN_FULL_PATH\`\`echo \$PHPMYADMIN_FOLDER_NAME\`

# Remove old installation (Optional)
rm \`echo \$PHPMYADMIN_FULL_PATH\`\`echo \$PHPMYADMIN_FOLDER_NAME\`_outdated -rf
EOL

# make phpmyadmin_auto_update.sh executable
chmod +x /usr/bin/phpmyadmin_auto_update.sh

/usr/bin/phpmyadmin_auto_update.sh
