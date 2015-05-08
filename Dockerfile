FROM debian:wheezy

RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y nasm gcc-multilib && \
	rm -rf /var/lib/apt/lists/*
