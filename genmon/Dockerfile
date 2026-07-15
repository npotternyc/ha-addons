ARG BUILD_FROM
FROM $BUILD_FROM

RUN apt update -y
RUN apt upgrade -y
RUN apt -y install sudo
RUN apt -y install python3 python3-venv

# Download genmon code
# Genmon upstream: https://github.com/jgyates/genmon (GPL-2.0)
RUN mkdir -p /app
RUN curl -L --no-progress-meter https://github.com/jgyates/genmon/archive/refs/tags/2.0.01.tar.gz | tar xz -C /app && mv /app/genmon* /app/genmon
RUN chmod 775 /app/genmon/startgenmon.sh && chmod 775 /app/genmon/genmonmaint.sh

# Update the genmon.conf file to write logs to persistent storage
RUN sed -i 's|loglocation = /var/log/|loglocation = /data/genmon/log|g' /app/genmon/conf/genmon.conf

# Update the genmon.conf file to use the TCP serial for ESP32 devices
RUN sed -i 's/use_serial_tcp = False/use_serial_tcp = True/g' /app/genmon/conf/genmon.conf
RUN sed -i 's/serial_tcp_port = 8899/serial_tcp_port = 6638/g' /app/genmon/conf/genmon.conf
RUN echo "update_check = false" >> /app/genmon/conf/genmon.conf

# Update MQTT default config
RUN sed -i 's/strlist_json = False/strlist_json = True/g' /app/genmon/conf/genmqtt.conf
RUN sed -i 's/flush_interval = 0/flush_interval = 60/g' /app/genmon/conf/genmqtt.conf
RUN sed -i 's/blacklist = Monitor,Run Time,Monitor Time,Generator Time,External Data/blacklist = Run Time,Monitor Time,Generator Time,Platform Stats,Communication Stats/g' /app/genmon/conf/genmqtt.conf

# Relax genserv.py framing headers so the web UI can load inside the
# Home Assistant ingress iframe (served from the same origin as HA).
# Genmon 2.0 hardcodes X-Frame-Options: DENY and CSP frame-ancestors 'none',
# which otherwise cause a "refused to connect" error in the ingress panel.
RUN sed -i "s/r.headers\[\"X-Frame-Options\"\] = \"DENY\"/r.headers[\"X-Frame-Options\"] = \"SAMEORIGIN\"/g" /app/genmon/genserv.py
RUN sed -i "s/\"frame-ancestors 'none'\"/\"frame-ancestors 'self'\"/g" /app/genmon/genserv.py

# Force genmonmaint.sh to use virtualenv by creating EXTERNALLY-MANAGED marker
RUN python3 -c "import sys,os; p=f'/usr/lib/python{sys.version_info.major}.{sys.version_info.minor}'; os.makedirs(p,exist_ok=True); open(f'{p}/EXTERNALLY-MANAGED','a').close()"

# Install Genmon requirements
RUN cd /app/genmon && ./genmonmaint.sh -i -n -s

# Configure startup script
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Clean up
RUN apt-get purge -y git build-essential libssl-dev libffi-dev python3-dev cargo swig liblgpio-dev && apt autoremove && apt clean ; \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*


EXPOSE 22
EXPOSE 443
EXPOSE 8000

CMD ["/app/run.sh"]
