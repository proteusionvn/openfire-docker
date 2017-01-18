#!/bin/bash

set -e

if [ ! -z "$1" ]; then
	exec "$@"
fi

# First, check for initial data:

if [ ! -d /var/cache/openfire-data/etc ]; then
	cp -pr /etc/openfire--SAVE /var/cache/openfire-data/etc
	echo "Copying base config files."
	# If we have a database host configured, then do that thang.
	if [ -n ${DATABASE_HOST} ]; then
		echo "  Preconfiguring Openfire"
		envsubst </etc/openfire--SAVE/openfire-postgres.xml >/var/cache/openfire-data/etc/openfire.xml
	fi
	chown -R openfire:openfire /var/cache/openfire-data/etc
fi
ln -sf /var/cache/openfire-data/etc /etc/openfire
if [ ! -d /var/cache/openfire-data/var ]; then
	echo "Copying data and plugin files."
	cp -pr /var/lib/openfire--SAVE /var/cache/openfire-data/var
else
	echo "Refreshing plugins."
	rm -rf /var/cache/openfire-data/var/plugins/admin
	cp -pr /var/lib/openfire--SAVE/plugins/admin /var/cache/openfire-data/var/plugins/
	for plugin in /var/lib/openfire--SAVE/plugins/*.jar; do
		cp -pr ${plugin} /var/cache/openfire-data/var/plugins/
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
