#!/usr/bin/env bash

set -euo pipefail

yolo=/tmp/yolo-"${RANDOM}"

echo -e "#!/usr/bin/env bash\nset -euo pipefail\necho hello all" >|"${yolo}"
## Run a script
# mount the script in /tmp to /script.sh in the container
docker run -it --rm -v "${yolo}":/script.sh:ro bash:latest bash /script.sh

# curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"
# curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"/ealenecho
# curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"/pisal
