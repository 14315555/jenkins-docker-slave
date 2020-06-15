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

ENV DOCKER_VERSION 1.12.3
ENV COMPOSE_VERSION 1.9.0

# We install newest docker into our docker in docker container
RUN \
curl -L https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz > /tmp/docker-${DOCKER_VERSION}.tgz \
 && tar -zxf /tmp/docker-${DOCKER_VERSION}.tgz -C /tmp \
 && cp /tmp/docker/docker /usr/local/bin/docker \
 && chmod +x /usr/local/bin/docker \
 && rm -rf /tmp/docker-${DOCKER_VERSION}.tgz /tmp/docker \
 && curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64 > /usr/bin/docker-compose \
 && chmod +x /usr/bin/docker-compose

#VOLUME /var/lib/docker
#VOLUME /var/lib/docker-compose

# check installation
RUN docker-compose -v

CMD ["/usr/sbin/sshd", "-D"]
