ARG BUILD_FROM
FROM $BUILD_FROM

# Install PowerTop and dependencies
RUN apk add --no-cache \
    powertop \
    bash \
    curl \
    kmod \
    cpufrequtils \
    python3 \
    py3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Flask via pip
RUN pip3 install --no-cache-dir --break-system-packages flask

# Create working directories
RUN mkdir -p /data/reports /app

# Copy run script and web interface
COPY run.sh /
COPY app/ /app/

# Make run script executable
RUN chmod a+x /run.sh

# Create powertop configuration directory
RUN mkdir -p /var/cache/powertop

# Set working directory
WORKDIR /data

# Expose web interface port
EXPOSE 8080

CMD ["/run.sh"]