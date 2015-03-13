FROM ubuntu:14.04
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
	apt-get update && \
  apt-get -y upgrade && \
	apt-get install -y nasm && \
	apt-get install -y gcc-multilib && \
	apt-get install -y build-essential nasm && \
	apt-get install -y gcc-multilib g++-multilib && \
	apt-get install -y software-properties-common && \
	rm -rf /var/lib/apt/lists/*
