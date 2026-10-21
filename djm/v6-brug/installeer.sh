#!/bin/bash
# DJM: zet de v6-installatie over op het brug-image (PHP >= 8.4.27). Draait als root op de Lychee-host.
# Gebruik: installeer.sh [map-van-de-installatie]   (standaard /opt/lychee)
# Terug: in docker-compose.yml de regel `image:` van lychee terugzetten op `lycheeorg/lychee` en `up -d`.
set -euo pipefail
DIR=${1:-/opt/lychee}
cd "$DIR"
[ -f docker-compose.yml ] || { echo "Geen docker-compose.yml in $DIR" >&2; exit 1; }
if docker compose version >/dev/null 2>&1; then DC="docker compose"; else DC=docker-compose; fi

mkdir -p v6-brug
curl -fsSL -o v6-brug/Dockerfile https://raw.githubusercontent.com/sjkanon/Lychee/devel/djm/v6-brug/Dockerfile
docker build -q -t lychee-v6-brug:local v6-brug >/dev/null
V=$(docker run --rm --entrypoint php lychee-v6-brug:local -r 'echo PHP_VERSION;')
echo "Brug-image: PHP $V"

[ -e docker-compose.yml.voor-brug ] || cp docker-compose.yml docker-compose.yml.voor-brug
# Alleen de image-regel van de dienst lychee (niet die van de database).
sed -i -E '/^  lychee:/,/^  [a-z_]+:/ s#^(    image: ).*lycheeorg/lychee.*#\1lychee-v6-brug:local#' docker-compose.yml
grep -q 'image: lychee-v6-brug:local' docker-compose.yml || { echo "image-regel niet gevonden" >&2; exit 1; }

# docker-compose 1.29 crasht bij het vervangen van een container met een nieuwer Docker (KeyError 'ContainerConfig')
# en laat dan een hernoemde, gestopte container achter. Daarom eerst weghalen; de gegevens staan in de mappen.
docker ps -aq --filter 'name=_lychee$' | xargs -r docker rm -f
$DC rm -sf lychee
$DC up -d lychee
for _ in $(seq 1 30); do
	S=$(docker inspect lychee --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}')
	[ "$S" = healthy ] && break
	sleep 5
done
echo "Container: $S, PHP in container: $(docker exec lychee php -r 'echo PHP_VERSION;')"
echo "HTTP: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/)"
