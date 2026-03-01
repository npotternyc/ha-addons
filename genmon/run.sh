mkdir -p /data/genmon/log
if [ ! -f "/data/genmon/log/genmon.log" ]; then
  touch /data/genmon/log/genmon.log
fi

/app/genmon/startgenmon.sh -c /data/genmon start && tail -F /data/genmon/log/genmon.log