srv=~/temp/srv
db=~/temp/filebrowser.db
config_json=./filebrowser.json

docker run \
  -v /path/to/root:"${srv}" \
  -v "${db}":/database.db \
  -v /path/.filebrowser.json:/.filebrowser.json \
  -u $(id -u):$(id -g) \
  -p 8080:80 \
  filebrowser/filebrowser
