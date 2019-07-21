# This Dockerfile is used to build an headles vnc image based on Centos

FROM centos:6

MAINTAINER Pengfei Ding "dingpf@fnal.gov"
ENV REFRESHED_AT 2019-07-08

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
 libuuid-devel \
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
