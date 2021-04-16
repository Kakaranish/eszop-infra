redis_password=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/redis_password" -H "Metadata-Flavor: Google")
sed "s/{redis_password}/$redis_password/g" /temp/redis_template.conf > /temp/redis.conf
mv -f /temp/redis.conf /etc/redis/redis.conf
chown redis:redis /etc/redis/redis.conf
systemctl restart redis