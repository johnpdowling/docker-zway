FROM ubuntu:xenial
MAINTAINER John Klimek <jklimek@gmail.com> (@sofakng)

ENV LD_LIBRARY_PATH=/opt/z-way-server/libs
ENV PATH=/opt/z-way-server:$PATH
ENV ZWAY_VERSION=3.0.6
ENV ZWAY_DIR=/opt/z-way-server

# Install required packages
RUN apt-get update -y \
  && apt-get install -y \
    supervisor \
    curl \
    libcurl3 \
    libarchive13 \
    libavahi-compat-libdnssd1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Extra packages?
#   libc-ares2

# Download Z-Way Server for Ubuntu
RUN curl -SLO https://storage.z-wave.me/z-way-server/z-way-server-Ubuntu-v${ZWAY_VERSION}.tgz \
  && tar -zxvf z-way-server-Ubuntu-v${ZWAY_VERSION}.tgz -C /opt \
  && rm z-way-server-Ubuntu-v${ZWAY_VERSION}.tgz

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
