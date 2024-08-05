if [ ! -f "/var/log/genmon.log" ]; then
  touch /var/log/genmon.log
fi

if [ -d "/data/genmon" ]; then
  echo "Link etc/genmon to /data/genmon"
  sudo rm -r /etc/genmon 
else
  echo "Move and link etc/genmon to /data/genmon"
  mv /etc/genmon /data
fi
sudo ln -s /data/genmon /etc/

/app/genmon/startgenmon.sh start && tail -F /var/log/genmon.log