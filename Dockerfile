FROM alpine:3.21

RUN apk add --no-cache bash postfix postfix-pcre postfix-pgsql ruby ruby-json

ENV MAIL_RECEIVER_VERSION=v4.0.7-1
ENV MAIL_RECEIVER_SHA256=fa28b1aa84d8ef095edde67358c058e6e6fde1dd1105ba6dcb1b99e0c95aa6ca

RUN apk add --no-cache curl \
  && cd /tmp \
  && rm -rf $INSTALL_PATH \
  && curl -o mail-receiver.tar.gz -fSL https://github.com/foodcoopsat/mail-receiver/archive/${MAIL_RECEIVER_VERSION}.tar.gz \
  && echo "$MAIL_RECEIVER_SHA256  mail-receiver.tar.gz" | sha256sum -c - \
  && tar -xf mail-receiver.tar.gz \
  && mkdir -p /usr/local/lib/site_ruby \
  && mv mail-receiver-*/lib/mail_receiver /usr/local/lib/site_ruby \
  && mv mail-receiver-*/receive-mail /usr/local/bin/discourse-receive-mail \
  && sed -i 's/ENV_FILE, ARGV.first/ARGV[0], ARGV[1]/g' /usr/local/bin/discourse-receive-mail \
  && rm -rf mail-receiver*

COPY start.sh /start.sh

EXPOSE 25
EXPOSE 465
EXPOSE 587
VOLUME /var/spool/postfix
CMD ["/start.sh"]
