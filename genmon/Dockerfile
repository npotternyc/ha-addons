ARG BUILD_FROM
FROM $BUILD_FROM

RUN apt update -y
RUN apt upgrade -y
RUN apt -y install sudo
RUN apt -y install python3.11 python3.11-venv

# Download genmon code
RUN mkdir -p /app
RUN curl -L --no-progress-meter https://github.com/jgyates/genmon/archive/refs/tags/V1.19.02.tar.gz | tar xz -C /app && mv /app/genmon* /app/genmon
RUN chmod 775 /app/genmon/startgenmon.sh && chmod 775 /app/genmon/genmonmaint.sh

# Update the genmon.conf file to use the TCP serial for ESP32 devices
RUN sed -i 's/use_serial_tcp = False/use_serial_tcp = True/g' /app/genmon/conf/genmon.conf
RUN sed -i 's/serial_tcp_port = 8899/serial_tcp_port = 6638/g' /app/genmon/conf/genmon.conf
RUN echo "update_check = false" >> /app/genmon/conf/genmon.conf

# Update MQTT default config
RUN sed -i 's/strlist_json = False/strlist_json = True/g' /app/genmon/conf/genmqtt.conf
RUN sed -i 's/flush_interval = 0/flush_interval = 60/g' /app/genmon/conf/genmqtt.conf
RUN sed -i 's/blacklist = Monitor,Run Time,Monitor Time,Generator Time,External Data/blacklist = Run Time,Monitor Time,Generator Time,Platform Stats,Communication Stats/g' /app/genmon/conf/genmqtt.conf

# Force to use virtualenv
RUN mkdir -p /usr/lib/python3.11
RUN echo '' >> /usr/lib/python3.11/EXTERNALLY-MANAGED

# Install Genmon requirements
RUN cd /app/genmon && ./genmonmaint.sh -i -n -s

# Configure startup script
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Clean up
RUN apt-get purge -y git build-essential libssl-dev libffi-dev python3-dev cargo && apt autoremove && apt clean ; \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*


EXPOSE 22
EXPOSE 443
EXPOSE 8000

CMD ["/app/run.sh"]

# annotation labels according to
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.title="Genmon Docker Image"
LABEL org.opencontainers.image.description="Image to run an instance of Genmon"
LABEL org.opencontainers.image.url="https://github.com/m0ngr31/genmon"
LABEL org.opencontainers.image.documentation="https://github.com/m0ngr31/genmon#readme"
LABEL org.opencontainers.image.licenses="GPL-2.0"
LABEL org.opencontainers.image.authors="Joe Ipson"
