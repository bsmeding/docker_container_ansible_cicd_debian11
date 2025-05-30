FROM debian:bullseye
LABEL maintainer="Bart Smeding"
ENV container=docker

ARG DEBIAN_FRONTEND=noninteractive

ENV pip_packages "ansible==8.6.0 cryptography yamllint pynautobot pynetbox jmespath netaddr"

# Install requirements.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo \
       systemd \
       systemd-sysv \
       build-essential \
       wget \
       libffi-dev \
       libssl-dev \
       procps \
       python3-pip \
       python3-dev \
       python3-setuptools \
       python3-wheel \
       python3-apt \
       iproute2 \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# Install Docker CLI and Python SDK
RUN apt-get update && apt-get install -y \
    docker.io \
    python3-docker \
    && rm -rf /var/lib/apt/lists/*

# Set system python to Externally managed
RUN rm -f /usr/lib/python3.11/EXTERNALLY-MANAGED

# Upgrade pip to latest version
RUN pip3 install --upgrade pip

# Install Ansible and other packages via Python pip
RUN pip3 install $pip_packages

# Set Ansible localhost inventory file
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# Make sure systemd doesn't start agettys on tty[1-6]
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]