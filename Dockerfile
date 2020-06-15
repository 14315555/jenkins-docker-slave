FROM ubuntu:18.04

LABEL maintainer="Patricia Mateo <patricia.mateo@sngular.com>"

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 8 (latest stable edition at 2019-04-01)
    apt-get install -qy openjdk-8-jdk && \
# Install maven
    apt-get install -qy maven && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user jenkins to the image
    adduser --quiet jenkins && \
# Set password for the jenkins user (you may want to alter this).
    echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2

RUN \
sed -i 's@http://archive.ubuntu.com/ubuntu/@http://ubuntu.osuosl.org/ubuntu@g' /etc/apt/sources.list && \
apt-get update && \
apt-get -y install software-properties-common wget curl jq git iptables ca-certificates apparmor && \
add-apt-repository ppa:webupd8team/java -y && \
apt-get update

#ADD settings.xml /home/jenkins/.m2/
# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/
# Standard SSH port
EXPOSE 22

# We install newest docker into our docker in docker container
RUN \
curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && \
tar --strip-components=1 -xvzf docker-latest.tgz -C /usr/local/bin && \
chmod +x /usr/local/bin/docker && \
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose

RUN docker-compose --version

VOLUME /var/lib/docker
VOLUME /var/lib/docker-compose


CMD ["/usr/sbin/sshd", "-D"]