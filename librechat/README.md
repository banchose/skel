# What

- You need to set things like api keys in the .env file in the root of the repo. 
- openrouter doesn't seem to support `user_provided` so I manually pasted in the OR key.
- Then, you need to mount the librechat.yaml to as a file in the /app of the container which is done in the docker-compose.override.yml
-It will pick up the /app/librechat.yml.  docker compose up with out sending to bg and note any errors
