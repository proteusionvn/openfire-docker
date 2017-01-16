#
# Dockerfile to build a docker image from Openfire Master
#
# Dave Cridland <dave.cridland@surevine.com>
# Copyright 2017 Surevine Ltd
#
# Interesting ports: 5222 (C2S) 5269 (S2S) 9090 (Admin) 9191 (Admin Secure)

# Use Ubuntu 16.04 LTS. Because.
FROM ubuntu:xenial
MAINTAINER Dave Cridland <dave.cridland@surevine.com>

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64

# Update system
RUN apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y && apt-get clean

# Install dependencies.
RUN apt-get install ant git openjdk-8-jdk-headless debhelper dpkg locales libc-bin default-jdk patchutils cdbs -y

# Arguments::
# git repo (your local, or the default Ignite's)
ARG OPENFIRE_GIT=https://github.com/igniterealtime/openfire
ARG OPENFIRE_GIT_COMMIT=master

# Clone sources
WORKDIR /var/tmp/src
RUN git clone $OPENFIRE_GIT && \
	cd openfire && \
	git checkout $OPENFIRE_GIT_COMMIT && \
	make && \
	make plugins && \
	make JAVA_HOME=${JAVA_HOME} dpkg && \
	cd /var/tmp/src/openfire/target/release/debian && \
	dpkg -i openfire*.deb && \
	cd /var/tmp && \
	rm -rf src && \
	touch /.firstboot.tmp

# Ports:
EXPOSE 5222
# XMPP C2S, StartTLS
EXPOSE 5223
# XMPP C2S, immediate-mode TLS
EXPOSE 5269
# XMPP S2S (federation)
EXPOSE 9090
# HTTP Admin Console
EXPOSE 9191
# HTTPS Admin Console
EXPOSE 7070
# HTTP BOSH binding
EXPOSE 7443
# HTTPS BOSH binding

COPY launch-openfire.sh /sbin/launch-openfire.sh
RUN chmod 0755 /sbin/launch-openfire.sh && \
	mv /etc/openfire /etc/openfire--SAVE && \
	mv /var/lib/openfire /var/lib/openfire--SAVE && \
	rm -rf /var/log/openfire
VOLUME /var/cache/openfire-data

ENTRYPOINT ["/sbin/launch-openfire.sh"]
