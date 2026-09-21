ARG BUILD_FROM
FROM $BUILD_FROM

# Install TLP
RUN apk add --no-cache tlp

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]