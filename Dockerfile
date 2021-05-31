#replace latest with ubuntu version eg. ubuntu:18.04
FROM ubuntu:latest

LABEL maintener="gautamj@cdac.in" purpose="Day 1 nmap+wireshark"

#all basic tools
ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND noninteractive
RUN \
    apt-get update && \
    apt-get -y install \
    debconf-utils \
    sudo \
    nano \
    net-tools \
    iputils-ping \
    wget \
    telnet \
    curl \
    dnsutils \
    firefox \
    openssh-server \
    ufw && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo tzdata tzdata/Areas select "Asia" |  debconf-set-selections && \
    echo tzdata tzdata/Zones/Asia select "Kolkata" |   debconf-set-selections && \
    echo keyboard-configuration keyboard-configuration/layout select 'English (US)' | debconf-set-selections && \
    echo keyboard-configuration keyboard-configuration/layoutcode select 'us'

#rdp tools
RUN \
    apt-get -y install \
    tzdata \
    keyboard-configuration \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    x11-xserver-utils && \
    adduser xrdp ssl-cert && \
    sed -i.bak '/fi/a #xrdp multiple users configuration n xfce-session n' /etc/xrdp/startwm.sh && \
    adduser --gecos "" --disabled-password vlab && \
#set user password
    echo "vlab:cd@c.hyder@b@d" | chpasswd && \
#set root password
    echo "root:cd@c.hyder@b@d.root" | chpasswd && \
#set xfce terminal as default
    echo 2 | sudo update-alternatives --config x-terminal-emulator

#tools related to lab
RUN \
	apt-get -y install \
	nmap \
	wireshark \
	g++

#nmap permission
RUN echo "vlab	ALL=NOPASSWD:/usr/bin/nmap" >> /etc/sudoers

#wireshark permission
RUN addgroup -system wireshark
RUN chown root:wireshark /usr/bin/dumpcap
RUN setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap

#teamviewer
RUN \
cd /tmp/ && \
wget https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc && \
sudo apt-key add TeamViewer2017.asc && \
sudo sh -c 'echo "deb http://linux.teamviewer.com/deb stable main" >> /etc/apt/sources.list.d/teamviewer.list'

#RUN \
#sudo apt-get update && \
#sudo apt-get -y install teamviewer

#configure teamviewer
#
#RUN \
#	echo "kumargautamburman@gmail.com" | sudo teamviwer setup

#add user to required groups
RUN usermod -a -G wireshark,root,sudo,xrdp vlab

#set firfox as default application for pdf files
RUN \
echo "application/pdf=firefox.desktop" >> /etc/xfce4/defaults.list && \
echo "application/x-bzpdf=firefox.desktop" >> /etc/xfce4/defaults.list && \
echo "application/x-gzpdf=firefox.desktop" >> /etc/xfce4/defaults.list && \
echo "application/x-xzpdf=firefox.desktop" >> /etc/xfce4/defaults.list

#start.sh contains all services that needs to be in running state as containers start
COPY start.sh /home/vlab/
RUN chmod +x /home/vlab/start.sh

#expose ports for necessary services eg . EXPOSE 3389 22 80
EXPOSE 3389

WORKDIR /home/vlab
ENTRYPOINT ["/home/vlab/start.sh", "bash" ]
