#!/bin/bash

set -e

if [ ! -z "$1" ]; then
	exec "$@"
fi

# First, check for initial data:

if [ ! -d /var/cache/openfire-data/etc ]; then
	cp -prv /etc/openfire--SAVE /var/cache/openfire-data/etc
fi
ln -sf /var/cache/openfire-data/etc /etc/openfire
if [ ! -d /var/cache/openfire-data/var ]; then
	cp -prv /var/lib/openfire--SAVE /var/cache/openfire-data/var
else
	rm -rf /var/cache/openfire-data/var/plugins/admin
	cp -prv /var/lib/openfire--SAVE/plugins/admin /var/cache/openfire-data/var/plugins/
	for plugin in /var/lib/openfire--SAVE/plugins/*.jar; do
		cp -prv ${plugin} /var/cache/openfire-data/var/plugins/
	done
fi
ln -sf /var/cache/openfire-data/var /var/lib/openfire
if [ ! -d /var/log/openfire ]; then
	mkdir -p /var/cache/openfire-data/log
	chown -R openfire:openfire /var/cache/openfire-data/log
fi
ln -sf /var/cache/openfire-data/log /var/log/openfire

# OK, now start openfire:

exec /usr/bin/java -server -DopenfireHome=/usr/share/openfire -Dopenfire.lib.dir=/usr/share/openfire/lib -classpath /usr/share/openfire/lib/startup.jar -jar /usr/share/openfire/lib/startup.jar
