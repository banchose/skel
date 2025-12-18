

find the port that traefik is using for the service
go to the dashboard and look or,

docker-compose.yml
         - "traefik.http.services.librechat.loadbalancer.server.port=3080"

## On the docker server

```sh
docker exec -it  pisal-traefik-1 sh -c 'nslookup LibreChat'
curl http://172.20.0.6:3080
# or
docker exec -it pisal-traefik-1 wget -O- http://LibreChat:3080
```
