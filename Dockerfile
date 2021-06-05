FROM ubuntu:focal
MAINTAINER John Dowling <john.patrick.dowling@gmail.com> (@johnpdowling)
#forked MAINTAINER John Klimek <jklimek@gmail.com> (@sofakng)

ENV LD_LIBRARY_PATH=/opt/z-way-server/libs
ENV PATH=/opt/z-way-server:$PATH
ENV ZWAY_VERSION=3.1.4
ENV ZWAY_DIR=/opt/z-way-server

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install additional packages that help to add Z-Wave.Me repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        dirmngr \
        apt-transport-https \
	  gnupg \
	  wget && \
# Add Z-Wave.Me repository
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x7E148E3C && \
    echo "deb https://repo.z-wave.me/z-way/ubuntu focal main" > /etc/apt/sources.list.d/z-wave-me.list && \
# Add mosquitto repository
#    wget http://repo.mosquitto.org/ubuntu/mosquitto-repo.gpg.key && \
#    apt-key add mosquitto-repo.gpg.key && \
#    wget http://repo.mosquitto.org/debian/mosquitto-stretch.list -P /etc/apt/sources.list.d/ && \
#    apt-add-repository ppa:mosquitto-dev/mosquitto-ppa && \
    apt-get update && \
# upgrade and install everything zway needs itself in one go
    apt-get install --reinstall -y --no-install-recommends \
        mosquitto \
      	mosquitto-clients \
        z-way-full \
        z-way-server \
        zbw \
        webif \

# Install required packages
#RUN apt-get update -y \
#  && apt-get install -y \
#    supervisor \
#    curl \
#    libcurl3 \
#    libarchive13 \
#    libavahi-compat-libdnssd1 \
#    libavahi-compat-libdnssd-dev
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Extra packages?
#   libc-ares2

# Download Z-Way Server for Ubuntu
#RUN curl -SLO https://storage.z-wave.me/z-way-server/z-way-3.1.4_amd64.deb \
#  && apt-get install ./z-way-3.1.4_amd64.deb

#RUN curl -SLO https://storage.z-wave.me/z-way-server/z-way-server-Ubuntu-v${ZWAY_VERSION}.tgz \
#  && tar -zxvf z-way-server-Ubuntu-v${ZWAY_VERSION}.tgz -C /opt \
#  && rm z-way-server-Ubuntu-v${ZWAY_VERSION}.tgz

# Configure box type for Z-Way (not sure if needed?)
RUN mkdir -p /etc/z-way  \
  && echo "VERSION_STRING" > /etc/z-way/VERSION \
  && echo "ubuntu" > /etc/z-way/box_type

# Setup supervisord to monitor/autorestart
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Export the web interface port
EXPOSE 8083

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
