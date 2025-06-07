ARG BUILD_FROM
FROM $BUILD_FROM

# Install PowerTop and dependencies
RUN apk add --no-cache \
    powertop \
    bash \
    curl \
    python3 \
    py3-pip \
    py3-flask \
    && rm -rf /var/cache/apk/*

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