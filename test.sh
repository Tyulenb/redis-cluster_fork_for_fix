MASTER_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker compose ps -q master))
SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker compose ps -q slave))
SENTINEL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker compose ps -q sentinel))

echo "Redis master: $MASTER_IP"
echo "Redis Slave: $SLAVE_IP"
echo "------------------------------------------------"
echo "Initial status of sentinel"
echo "------------------------------------------------"

docker exec $(docker compose ps -q sentinel) redis-cli -p 26379 info Sentinel

echo "Current master is:"
docker exec $(docker compose ps -q sentinel) redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
echo "------------------------------------------------"

echo "Stopping Redis master..."
docker pause $(docker compose ps -q master)
echo "Waiting for 10 seconds..."
sleep 10

echo "Current information of sentinel after stopping master:"
docker exec $(docker compose ps -q sentinel) redis-cli -p 26379 info Sentinel
echo "Current master is:"
docker exec $(docker compose ps -q sentinel) redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
echo "------------------------------------------------"

echo "Restarting Redis master..."
docker unpause $(docker compose ps -q master)
sleep 5

echo "Current information of sentinel after restarting master:"
docker exec $(docker compose ps -q sentinel) redis-cli -p 26379 info Sentinel
echo "Current master is:"
docker exec $(docker compose ps -q sentinel) redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
