# Traefik Troubleshooting

## Check loadbalancer servers

- Mind the `?` to skip nulls
- These are the paths to the containers on the docker network
- ssh star and curl the endpoints

```sh
curl -s -L https://traefik.xaax.dev/api/http/services | jq '.[].loadBalancer.servers.[]?.url'

ssh star
# certs don't matter just prefix expected /
# or curl -L localhost:8080 for the api
# curl -v -L http://localhost:8080/api/http/services | jq '.[].loadBalancer.servers.[]?.url'
# loop through each endpoint
# for i in $(curl -v -L http://localhost:8080/api/http/services | jq -r '.[].loadBalancer.servers.[]?.url');do curl -L "$i";done
curl "http://172.19.0.6:80"
```
