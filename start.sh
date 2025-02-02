#!/bin/sh

cp /etc/postfix/originals/* /etc/postfix/

discourse_id=0
while read base_url api_username api_key; do
  if [ ! -z "$base_url" ]
  then
  cat << EOF > /etc/postfix/discourse_instance_$discourse_id.json
{
  "DISCOURSE_BASE_URL": "https://$base_url",
  "DISCOURSE_API_USERNAME": "$api_username",
  "DISCOURSE_API_KEY": "$api_key"
}
EOF
  cat << EOF >> /etc/postfix/master.cf
discourse_$discourse_id  unix  -       n       n       -       -       pipe user=nobody:nogroup
  argv=/usr/local/bin/discourse-receive-mail /etc/postfix/discourse_instance_$discourse_id.json \${recipient}
EOF
  echo "$base_url discourse_$discourse_id:" >> /etc/postfix/transport.map
  discourse_id=$((discourse_id+1))
  fi
done < $DISCOURSE_INSTANCES_FILE

relay_domains=""
while read domain rest; do
  relay_domains="${relay_domains},${domain}"
  echo "noreply@${domain} 550 mailbox unavailable" >> /etc/postfix/recipient_list.map
done < /etc/postfix/transport.map

echo "relay_domains = ${relay_domains:1}" >> /etc/postfix/main.cf

postmap /etc/postfix/*.map
chown root:root /etc/postfix/*.db
chmod 0600 /etc/postfix/*.db

# Actually run Postfix
exec postfix start-fg
