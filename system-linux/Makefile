SHELL        = /bin/bash
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
NOW          := $(shell date "+%Y-%m-%d.%Hh%Mm%Ss")
ALPHAUSB     := wlan1
MBWIFI    := wlan0

# --------------------------------------------------------------------------------------
# System tools
# --------------------------------------------------------------------------------------

SSH_SSHCTL       = /etc/init.d/ssh

APACHE_APACHECTL = /usr/sbin/apachectl
APACHE_A2ENSITE  = /usr/sbin/a2ensite
APACHE_A2DISSITE = /usr/sbin/a2dissite
APACHE_A2ENMOD   = /usr/sbin/a2enmod
APACHE_DIR_LOG   = /var/log/apache2

MYSQL_MYSQL      = /usr/bin/mysql
MYSQL_MYSQLDUMP  = /usr/bin/mysqldump

PROFTP           = /etc/init.d/proftpd

SEAFILE_ROOT     = /home/seafile/seafile/seafile-server-4.2.2
SEAFILE_SH       = $(SEAFILE_ROOT)/seafile.sh
SEAHUB_SH        = $(SEAFILE_ROOT)/seahub.sh

BIND_RC          = /etc/init.d/bind9
BIND_NAMEDCONF   = /usr/sbin/named-checkconf
BIND_ZONE        = beurive.ovh
BIND_IP          = 48.67.196.5

# --------------------------------------------------------------------------------------
# User management
# --------------------------------------------------------------------------------------

user-create:
	adduser $(user)
	addgroup $(user) root
	addgroup $(user) adm
	addgroup $(user) sudo
	adduser $(user) sshusers
	su - $(user) -c "mkdir .ssh && chmod -R 700 ~/.ssh"

# --------------------------------------------------------------------------------------
# SSHD
# --------------------------------------------------------------------------------------

sshd-check:
	sshd -t

sshd-restart:
	sshd -t && /etc/init.d/ssh restart

# --------------------------------------------------------------------------------------
# FTP
# --------------------------------------------------------------------------------------

ftp-start:
	$(PROFTP) start

ftp-stop:
	$(PROFTP) stop

# --------------------------------------------------------------------------------------
# Apache WEB
# Specific usages: make apache-enable-site site=toto
# --------------------------------------------------------------------------------------

apache-version:
	$(APACHE_APACHECTL) -v

apache-conf-dump:
	less /etc/apache2/apache2.conf

apache-debug:
	netstat -nlp | grep '80\|httpd'
	tail -f $(APACHE_DIR_LOG)/error.log -f $(APACHE_DIR_LOG)/access.log

apache-check-conf:
	$(APACHE_APACHECTL) configtest

apache-check-vhost:
	$(APACHE_APACHECTL) -S

apache-check-all:
	$(MAKE) apache-check-conf
	$(MAKE) apache-check-vhost

apache-stop:
	$(APACHE_APACHECTL) -k stop && echo $$?

apache-start:
	$(APACHE_APACHECTL) -k start && echo $$?

apache-start-debug:
	-$(APACHE_APACHECTL) -e debug -k start && echo $$?
	$(MAKE) apache-debug

apache-restart:
	$(MAKE) apache-check-all
	-$(APACHE_APACHECTL) -e info -k restart && echo $$?
	tail -10 $(APACHE_DIR_LOG)/error.log

apache-enable-site:
	$(APACHE_A2ENSITE) $(site)
	$(MAKE) apache-restart

apache-disable-site:
	$(APACHE_A2DISSITE) $(site)
	$(MAKE) apache-restart

apache-enable-module:
	$(APACHE_A2ENMOD) $(module)

apache-list-module:
	$(APACHE_APACHECTL) -M

# --------------------------------------------------------------------------------------
# Seafile
# --------------------------------------------------------------------------------------

seafile-start:
	$(SEAFILE_SH) start
	$(SEAHUB_SH) start-fastcgi 8000

seafile-stop:
	$(SEAHUB_SH) stop
	$(SEAFILE_SH) stop

seafile-restart:
	$(MAKE) seafile-stop
	$(MAKE) seafile-start

seafile-debug:
	pgrep -f seafile-controller
	pgrep -f "manage.py run_gunicorn"
	tail -f $(APACHE_DIR_LOG)/error.log -f $(APACHE_DIR_LOG)/access.log

# --------------------------------------------------------------------------------------
# PHP
# --------------------------------------------------------------------------------------

php-conf-file:
	php -i | grep 'Configuration File' | perl -ne 'if ($$_ =~ m/^Loaded .+=> (.+)$$/) { print "$$1\n"; }'

php-conf-timezone:
	php -i | grep 'Configuration File' | perl -ne 'if ($$_ =~ m/^Loaded .+=> (.+)$$/) { print "$$1\n"; }' | xargs grep 'date.timezone'

# --------------------------------------------------------------------------------------
# BIND
# --------------------------------------------------------------------------------------

bind-restart:
	$(BIND_RC) reload

bind-check:
	$(BIND_NAMEDCONF) -z && echo $$?

# --------------------------------------------------------------------------------------
# Wifi
# Specific usage: make wifi-get-ap ap="Bouygues Telecom Wi-Fi" ch=1
# --------------------------------------------------------------------------------------

wifi-adapter-show:
	airmon-ng

wifi-mac:
	ifconfig

wifi-restart:
	/etc/init.d/network stop
	/etc/init.d/network start

# --------------------------------------------------------------------------------------
# Wifi integrated to the mother booard
# --------------------------------------------------------------------------------------

wifi-mb-desactivate:
	iw $(APLPHAPCI) del

wifi-mb-change-mac:
	ifconfig $(MBWIFI) down
	macchanger -a $(MBWIFI)
	ifconfig $(MBWIFI) up
	ifconfig $(MBWIFI)

wifi-mb-get-ap:
	airodump-ng --essid="$(ap)" $(MBWIFI)

wifi-mb-disconnect-all:
	# ifconfig $(ALPHAUSB) down
	# sleep 2
	# iwconfig $(ALPHAUSB) channel $(ch)
	# ifconfig $(ALPHAUSB) up
	aireplay-ng -0 1 -a $(mac)  --ignore-negative-one  $(MBWIFI)

# --------------------------------------------------------------------------------------
# Wifi USB ALPHA
# --------------------------------------------------------------------------------------

wifi-usb-change-mac:
	ifconfig $(ALPHAUSB) down
	macchanger -a $(ALPHAUSB)
	ifconfig $(ALPHAUSB) up
	ifconfig $(ALPHAUSB)

wifi-usb-get-ap:
	airodump-ng --essid="$(ap)" $(ALPHAUSB)

wifi-usb-disconnect-all:
	# ifconfig $(ALPHAUSB) down
	# sleep 2
	# iwconfig $(ALPHAUSB) channel $(ch)
	# ifconfig $(ALPHAUSB) up
	aireplay-ng -0 1 -a $(mac)  --ignore-negative-one  $(ALPHAUSB)

# --------------------------------------------------------------------------------------
# Network manager
# Make sure to disable "hostapd" and "dnsmask" at boot time:
#      -> update-rc.d hostapd disable
#      -> update-rc.d dnsmasq disable
# --------------------------------------------------------------------------------------

network-manager-stop:
	stop network-manager

network-manager-start:
	start network-manager

ap-up:
	$(MAKE) network-manager-stop
	# WARNING: "hostapd" and "dnsmask" should not be running:
	#
	# /etc/init.d/hostapd stop
	# /etc/init.d/dnsmasq stop
	cp /etc/network/wifi/interfaces.wlan0 /etc/network/interfaces
	ifdown wlan0
	ifup wlan0
	cp /etc/dnsmasq.conf.wlan0 /etc/dnsmasq.conf
	/etc/init.d/hostapd start
	/etc/init.d/dnsmasq start

ap-down:
	/etc/init.d/hostapd stop
	/etc/init.d/dnsmasq stop
	cp /etc/network/interfaces.org /etc/network/interfaces
	ifdown wlan0
	ifup wlan0
	$(MAKE) network-manager-start




