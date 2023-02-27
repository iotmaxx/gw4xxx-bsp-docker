FROM eclipse-temurin:11.0.17_8-jdk-focal as jre-build

# Generate smaller java runtime without unneeded files
# for now we include the full module path to maintain compatibility
# while still saving space
RUN jlink \
         --add-modules ALL-MODULE-PATH \
         --no-man-pages \
         --compress=2 \
         --output /javaruntime

FROM debian:bullseye

# jenkins
ARG jk_user=jenkins
ARG jk_passwd=jenkins
ARG jk_group=jenkins
ARG jk_uid=1001
ARG jk_gid=1001
ARG JENKINS_AGENT_HOME=/home/${jk_user}

ENV JENKINS_AGENT_HOME=${JENKINS_AGENT_HOME}
ARG AGENT_WORKDIR="${JENKINS_AGENT_HOME}"/agent
# Persist agent workdir path through an environment variable for people extending the image
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

RUN groupadd -g ${jk_gid} ${jk_group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${jk_uid}" -g "${jk_gid}" -m -s /bin/bash "${jk_user}" \
    && echo "${jk_user}:${jk_passwd}" | chpasswd \
    # Prepare subdirectories
    && mkdir -p "${JENKINS_AGENT_HOME}/.ssh/" "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}/.jenkins" \
    # Make sure that user 'jenkins' own these directories and their content
    && chown -R "${jk_uid}":"${jk_gid}" "${JENKINS_AGENT_HOME}" "${AGENT_WORKDIR}"

# ptxdist
ARG PTXDIST_VERSION=2022.04.0
ARG PTXDIST_VERSION_TOOLCHAIN=2021.07.0
ARG OSELAS_TOOLCHAIN_VERSION=2021.07.0
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
##RUN echo 'deb [trusted=yes] https://debian.pengutronix.de/debian/ bullseye main contrib non-free' > /etc/apt/sources.list.d/pengutronix.list
##RUN apt -o="Acquire::AllowInsecureRepositories=true" update
#RUN apt-get -o='Acquire::https::debian.pengutronix.de::Verify-Peer=false' update
RUN apt-get update
##RUN apt-get install -o='Acquire::https::debian.pengutronix.de::Verify-Peer=false' -y -qq pengutronix-archive-keyring
#Install all necessary packages
RUN DEBIAN_FRONTEND=noninteractive TZ="Europe/Berlin" apt-get install -y tzdata
RUN apt-get install -y -qq \
	gcc \
	pkg-config \
	libncurses-dev \
	gawk flex bison texinfo make file \
	gettext patch python3-dev python3-setuptools unzip bc wget \
	python3-pip python3-sphinx \
	nano less git ncurses-dev sudo \
	git-lfs netcat-traditional openssh-server \
	moreutils \
##	oselas.toolchain-2021.07-arm-v7a-linux-gnueabi \
#	oselas.toolchain-2019.09.1-arm-v7a-linux-gnueabihf-gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized \
#	oselas.toolchain-2019.09.1-arm-v7a-linux-gnueabihf-gcc-9.2.1-clang-8.0.1-glibc-2.30-binutils-2.32-kernel-5.0-sanitized \
	&& apt clean

# add pengutronix repository
RUN echo 'deb [trusted=yes] https://debian.pengutronix.de/debian/ bullseye main contrib non-free' > /etc/apt/sources.list.d/pengutronix.list
RUN apt -o="Acquire::AllowInsecureRepositories=true" update
RUN apt-get install -o='Acquire::https::debian.pengutronix.de::Verify-Peer=false' -y -qq pengutronix-archive-keyring
RUN apt -o="Acquire::AllowInsecureRepositories=true" update
RUN apt-get install -o='Acquire::https::debian.pengutronix.de::Verify-Peer=false' -y -qq \
        oselas.toolchain-2021.07-arm-v7a-linux-gnueabihf \
#       oselas.toolchain-2019.09.1-arm-v7a-linux-gnueabihf-gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized \
#       oselas.toolchain-2019.09.1-arm-v7a-linux-gnueabihf-gcc-9.2.1-clang-8.0.1-glibc-2.30-binutils-2.32-kernel-5.0-sanitized \
        && apt clean

# add github cli
#RUN wget -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor > /usr/share/keyrings/githubcli-archive-keyring.gpg
#RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
#RUN apt update
#RUN apt install gh -y

# for building the ptxdist PDF documentation
#RUN apt-get -y -qq install latexmk texlive-xetex texlive-fonts-extra
#create new user without password
RUN adduser $jk_user sudo
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# setup SSH server
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd

# VOLUME directive must happen after setting up permissions and content
VOLUME "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}"/.jenkins "/tmp" "/run" "/var/run"
#WORKDIR "${JENKINS_AGENT_HOME}"

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

RUN echo "PATH=${PATH}" >> /etc/environment
COPY setup-sshd /usr/local/bin/setup-sshd

#change user, because ptxdist doesnt run with root privileges
USER ${jk_user}

RUN mkdir -p "${JENKINS_AGENT_HOME}"/local && \
        cd "${JENKINS_AGENT_HOME}"/local && \
	wget https://public.pengutronix.de/software/ptxdist/ptxdist-${PTXDIST_VERSION}.tar.bz2 && \
	tar -xjf ptxdist-${PTXDIST_VERSION}.tar.bz2 && \
	cd ptxdist-${PTXDIST_VERSION} && \
	./configure && \
	make && \
	sudo make install

EXPOSE 22

ENTRYPOINT ["setup-sshd"]

#COPY expat.make /usr/local/lib/ptxdist-2021.05.0/rules/
#RUN cd /home/ptx/ && \
#  git clone git://git.pengutronix.de/DistroKit

WORKDIR "${JENKINS_AGENT_HOME}"
