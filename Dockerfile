FROM alpine:3.6

LABEL maintainer "yanxiangwang88@gmail.com"

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.name="aws-mosquitto-broker" \
    org.label-schema.url="" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/yanxiang-wang/aws_mosquitto_broker"


RUN apk --no-cache add mosquitto && \
    mkdir -p /mosquitto/config /mosquitto/data /mosquitto/log && \
    chmod -R 777 /mosquitto && \
    chown -R mosquitto:mosquitto /mosquitto

VOLUME ["/mosquitto/config", "/mosquitto/data", "/mosquitto/log"]

COPY /config /mosquitto/config
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
