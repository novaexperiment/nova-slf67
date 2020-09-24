# This Dockerfile is used to build an headles vnc image based on Centos

FROM centos:6

MAINTAINER Pengfei Ding "dingpf@fnal.gov"
ENV REFRESHED_AT 2020-08-13

RUN mkdir -p /etc/yum/vars \
 && echo 6.7 >  /etc/yum/vars/releasever \
 && rpm -ivh --force http://linux1.fnal.gov/linux/fermi/slf6.7/x86_64/os/FermiPackages/slf-release-6.7-1.x86_64.rpm \
 && rpm -Uvh https://repo.opensciencegrid.org/osg/3.4/osg-3.4-el6-release-latest.rpm \
 && yum -y erase centos-release \
 && yum -y distro-sync

RUN rpm --rebuilddb; yum install -y yum-plugin-ovl

RUN yum clean all \
 && yum -y install epel-release \
 && yum -y update \
 && yum -y install yum-plugin-priorities \
 nc perl expat-devel glibc-devel gdb time \
 freetype-devel libXpm openssl-devel libXmu-devel \
 mesa-libGL-devel mesa-libGLU-devel libjpeg libpng \
 tar zip xz bzip2 patch sudo which strace \
 upsupdbootstrap-fnal fermilab-util_kx509 krb5-fermi-base  \
 openssh-clients rsync tmux voms-clients-cpp vo-client  \
 xrootd-client svn git wget  \
 redhat-lsb-core gcc gstreamer gtk2-devel  \
 gstreamer-plugins-base-devel  \
 vim which net-tools bzip2 xorg-x11-fonts* \
 xorg-x11-server-utils xorg-x11-twm dbus dbus-x11 \
 libuuid-devel emacs evince eog \ 
 && yum clean all

RUN yum clean all \
 && yum --enablerepo=epel -y install osg-wn-client \
 && yum clean all

RUN yum clean all \
 && yum --enablerepo=epel -y install htop \
 && yum clean all

RUN yum clean all \
 && yum -y install openssh-server \
 && yum clean all

ENV UPS_OVERRIDE="-H Linux64bit+2.6-2.12"

RUN wget http://mirror.centos.org/centos/6/os/x86_64/Packages/subversion-perl-1.6.11-15.el6_7.x86_64.rpm \
 && rpm -Uvh subversion-perl-1.6.11-15.el6_7.x86_64.rpm \
 && rm -rf *.rpm

RUN yum clean all \
 && yum -y install unzip \
 && yum clean all
 
# Fix SSH Config
RUN rm /etc/ssh/ssh_config
RUN cat >/etc/ssh/ssh_config <<EOL
#	$OpenBSD: ssh_config,v 1.25 2009/02/17 01:28:32 djm Exp $

# This is the ssh client system-wide configuration file.  See
# ssh_config(5) for more information.  This file provides defaults for
# users, and the values can be changed in per-user configuration files
# or on the command line.

# Configuration data is parsed as follows:
#  1. command line options
#  2. user-specific file
#  3. system-wide file
# Any configuration value is only changed the first time it is set.
# Thus, host-specific definitions should be at the beginning of the
# configuration file, and defaults at the end.

# Site-wide defaults for some commonly used options.  For a comprehensive
# list of available options, their meanings and defaults, please see the
# ssh_config(5) man page.

# Host *
#   ForwardAgent no
#   ForwardX11 no
#   RhostsRSAAuthentication no
#   RSAAuthentication yes
#   PasswordAuthentication yes
#   HostbasedAuthentication no
#   GSSAPIAuthentication no
#   GSSAPIDelegateCredentials no
#   GSSAPIKeyExchange no
#   GSSAPITrustDNS no
#   BatchMode no
#   CheckHostIP yes
#   AddressFamily any
#   ConnectTimeout 0
#   StrictHostKeyChecking ask
#   IdentityFile ~/.ssh/identity
#   IdentityFile ~/.ssh/id_rsa
#   IdentityFile ~/.ssh/id_dsa
#   Port 22
#   Protocol 2,1
#   Cipher 3des
#   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
#   MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160
#   EscapeChar ~
#   Tunnel no
#   TunnelDevice any:any
#   PermitLocalCommand no
#   VisualHostKey no
Host 131.225.* *.fnal.gov *soudan.org
Protocol 2
GSSAPIAuthentication yes
GSSAPIDelegateCredentials yes
GSSAPIKeyExchange yes
ForwardX11Trusted yes
ForwardX11 yes
Host *
GSSAPIAuthentication yes
# If this option is set to yes then remote X11 clients will have full access
# to the original X11 display. As virtually no X11 client supports the untrusted
# mode correctly we set this to yes.
ForwardX11Trusted yes
# Send locale-related environment variables
SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
SendEnv XMODIFIERS
Protocol 2
GSSAPIDelegateCredentials yes
GSSAPIKeyExchange yes
ForwardX11 yes
EOL

# Create a me user (UID and GID should match the Mac user), add to suoders, and switch to it
ENV USERNAME=me

ARG MYUID
ENV MYUID=${MYUID:-1000}
ARG MYGID
ENV MYGID=${MYGID:-100}

RUN useradd -u $MYUID -g $MYGID -ms /bin/bash $USERNAME && \
      echo "$USERNAME ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME

ENTRYPOINT ["/bin/bash"]
