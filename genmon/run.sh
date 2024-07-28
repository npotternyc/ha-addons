if [ ! -f "/var/log/genmon.log" ]; then
  touch /var/log/genmon.log
fi

if [ ! -d "/etc/genmon" ]; then
  mkdir -p /etc/genmon
fi

/app/genmon/startgenmon.sh start && tail -F /var/log/genmon.log