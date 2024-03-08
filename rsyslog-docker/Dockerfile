FROM ubuntu:22.04
RUN apt-get update && apt-get install -y rsyslog && mkdir -p /logs
COPY rsyslog.conf /rsyslog.conf
ENTRYPOINT ["rsyslogd", "-n", "-f", "/rsyslog.conf"]
