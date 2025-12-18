## Help

- `docker run traefik[:version] --help`

- Configuration
  - Static startup: `/etc/traefik/traefik.yaml`
  - OR
  - command line like in docker compose

## static

## Configuration

- At startup, 3 **mutually exclusive** way
  - In configuration file
    - A file named:
      - traefik.yaml, traefik.yml, traefik.toml
    - In three locations
      - /etc/traefik # in the container
      - /$XDG_CONFIG_HOME/
      - $HOME/.config/
      - .
  - In the command line
  - As an environmental variable
