FROM ubuntu:focal

ARG PTXDIST_VERSION=2021.05.0
ARG PTXDIST_VERSION_TOOLCHAIN=2019.09.0
ARG OSELAS_TOOLCHAIN_VERSION=2019.09.1
ARG OSELAS_TOOLCHAIN_VERSION_GIT=v$OSELAS_TOOLCHAIN_VERSION
ARG USER=ptx
ARG UID=1000
ARG GID=1000
# default password for user
ARG PW=ptx

# Option1: Using unencrypted password/ specifying password
RUN useradd -d /home/ptx -m ${USER} --uid=${UID} && echo "${USER}:${PW}" | \
      chpasswd
#RUN export DEBIAN_FRONTEND=noninteractive
# add pengutronix repository
RUN echo 'deb [trusted=yes] https://debian.pengutronix.de/debian/ focal main contrib non-free' > /etc/apt/sources.list.d/pengutronix.list
#RUN apt -o="Acquire::AllowInsecureRepositories=true" update
RUN apt-get -o='Acquire::https::debian.pengutronix.de::Verify-Peer=false' update
#RUN apt-get update
RUN apt-get install -o='Acquire::https::debian.pengutronix.de::Verify-Peer=false' -y -qq pengutronix-archive-keyring
#Install all necessary packages
RUN DEBIAN_FRONTEND=noninteractive TZ="Europe/Berlin" apt-get install -y tzdata
RUN apt-get install -o='Acquire::https::debian.pengutronix.de::Verify-Peer=false' -y -qq \
	gcc \
	pkg-config \
	libncurses-dev \
	gawk flex bison texinfo make file \
	gettext patch python3-dev python3-setuptools unzip bc wget \
#	python-pip \
	python3-pip \
	python3-sphinx \
	nano less git \
	ncurses-dev \
	sudo \
#	oselas.toolchain-2019.09.1-arm-v7a-linux-gnueabihf-gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized \
	oselas.toolchain-2019.09.1-arm-v7a-linux-gnueabihf-gcc-9.2.1-clang-8.0.1-glibc-2.30-binutils-2.32-kernel-5.0-sanitized \
	&& apt clean

#create new user without password
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#change user, because ptxdist doesnt run with root privileges
USER ptx

RUN mkdir -p /home/ptx/local && \
        cd /home/ptx/local && \
	wget https://public.pengutronix.de/software/ptxdist/ptxdist-2021.05.0.tar.bz2 && \
	tar -xjf ptxdist-2021.05.0.tar.bz2 && \
	cd ptxdist-2021.05.0 && \
	./configure && \
	make && \
	sudo make install

COPY expat.make /usr/local/lib/ptxdist-2021.05.0/rules/
#RUN cd /home/ptx/ && \
#  git clone git://git.pengutronix.de/DistroKit

WORKDIR /home/ptx
