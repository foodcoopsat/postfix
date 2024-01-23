FROM alpine:3.19

RUN apk add --no-cache bash postfix postfix-pcre postfix-pgsql rsyslog ruby ruby-json

ENV MAIL_RECEIVER_VERSION=v4.0.7
ENV MAIL_RECEIVER_SHA256=b460235340619973fda34bca4753a23f34d89d08420ebfc0923779b73158d3c7

RUN apk add --no-cache curl \
  && cd /tmp \
  && rm -rf $INSTALL_PATH \
  && curl -o mail-receiver.tar.gz -fSL https://github.com/discourse/mail-receiver/archive/${MAIL_RECEIVER_VERSION}.tar.gz \
  && echo "$MAIL_RECEIVER_SHA256  mail-receiver.tar.gz" | sha256sum -c - \
  && tar -xf mail-receiver.tar.gz \
  && mkdir -p /usr/local/lib/site_ruby \
  && mv mail-receiver-*/lib/mail_receiver /usr/local/lib/site_ruby \
  && mv mail-receiver-*/receive-mail /usr/local/bin/discourse-receive-mail \
  && sed -i 's/ENV_FILE, ARGV.first/ARGV[0], ARGV[1]/g' /usr/local/bin/discourse-receive-mail \
  && rm -rf mail-receiver*

COPY rsyslog.conf /etc/rsyslog.conf
COPY start.sh /start.sh

EXPOSE 25
EXPOSE 465
EXPOSE 587
VOLUME /var/spool/postfix
CMD ["/start.sh"]
