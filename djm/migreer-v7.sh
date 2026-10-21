#!/bin/bash
# DJM: Lychee 6 → 7 op de Lychee-host (zie MIGRATIE.md). Draait als root, na een backup.
# Gebruik: migreer-v7.sh [map] [image]   (standaard /opt/lychee en ghcr.io/sjkanon/lychee-djm:latest-legacy)
# Neemt APP_KEY, database-wachtwoorden, APP_URL en TRUSTED_PROXIES over uit de v6-installatie; die komen alleen
# in .env (600), nergens in uitvoer.
set -euo pipefail
DIR=${1:-/opt/lychee}
IMG=${2:-ghcr.io/sjkanon/lychee-djm:latest-legacy}
RAW=https://raw.githubusercontent.com/sjkanon/Lychee/devel/djm
cd "$DIR"
[ -f config/.env ] && [ -f docker-compose.yml ] || { echo "Geen v6-installatie in $DIR" >&2; exit 1; }
[ ! -e .env ] || { echo ".env bestaat al: is $DIR al gemigreerd?" >&2; exit 1; }

env6() { sed -n "s/^$1=//p" config/.env | head -1 | sed -E 's/^"(.*)"$/\1/'; }
dc6() { sed -nE "s/^ +$1: *//p" docker-compose.yml | head -1 | sed -E "s/^['\"](.*)['\"]$/\1/"; }
APP_KEY=$(env6 APP_KEY)
APP_URL=$(env6 APP_URL)
DB_PASSWORD=$(dc6 DB_PASSWORD); [ -n "$DB_PASSWORD" ] || DB_PASSWORD=$(env6 DB_PASSWORD)
DB_ROOT_PASSWORD=$(dc6 MYSQL_ROOT_PASSWORD)
TRUSTED_PROXIES=$(dc6 TRUSTED_PROXIES); [ -n "$TRUSTED_PROXIES" ] || TRUSTED_PROXIES=$(env6 TRUSTED_PROXIES)
for v in APP_KEY APP_URL DB_PASSWORD DB_ROOT_PASSWORD TRUSTED_PROXIES; do
	[ -n "${!v}" ] || { echo "$v niet gevonden in de v6-installatie" >&2; exit 1; }
	# In .env tussen enkele quotes (Compose vult dan geen $ in); een ' erin kan dan niet.
	[[ ${!v} != *"'"* ]] || { echo "$v bevat een ' en kan niet in .env" >&2; exit 1; }
done
OWNER=$(stat -c %u uploads); GROUP=$(stat -c %g uploads)
[ "$OWNER" -ge 33 ] && [ "$GROUP" -ge 33 ] || { OWNER=33; GROUP=33; }

echo "== image"
docker pull -q "$IMG" >/dev/null
echo "PHP $(docker run --rm --entrypoint php "$IMG" -r 'echo PHP_VERSION;'), Lychee $(docker run --rm --entrypoint cat "$IMG" /app/version.md)"

echo "== v7-opzet"
curl -fsSL -o docker-compose.v7.yml "$RAW/docker-compose.yml"
(
	umask 077
	cat > .env <<EOF
APP_URL='$APP_URL'
APP_KEY='$APP_KEY'
TRUSTED_PROXIES='$TRUSTED_PROXIES'
DB_PASSWORD='$DB_PASSWORD'
DB_ROOT_PASSWORD='$DB_ROOT_PASSWORD'
APP_PORT=8080
PUID=$OWNER
PGID=$GROUP
LYCHEE_IMAGE=$IMG
EOF
)
mkdir -p logs tmp storage-app
chown "$OWNER:$GROUP" logs tmp storage-app
touch config/user.css config/custom.js
docker compose -f docker-compose.v7.yml config -q

echo "== v6 stoppen"
docker compose down
mv docker-compose.yml docker-compose.v6.yml
mv docker-compose.v7.yml docker-compose.yml

echo "== v7 starten (migraties kunnen even duren)"
docker compose up -d
for _ in $(seq 1 120); do
	S=$(docker inspect lychee --format '{{.State.Health.Status}}' 2>/dev/null || echo weg)
	[ "$S" = healthy ] && break
	[ "$S" = weg ] && { docker compose logs --tail 40 lychee; exit 1; }
	sleep 5
done
[ "$S" = healthy ] || { echo "lychee niet healthy ($S)"; docker compose logs --tail 60 lychee; exit 1; }

echo "== onderhoud"
docker compose exec -T lychee php artisan lychee:recompute-album-sizes || true
docker compose exec -T lychee php artisan lychee:recompute-album-stats || true

echo "== controle"
docker compose ps --format '{{.Name}}|{{.Image}}|{{.Status}}'
echo "PHP in container: $(docker exec lychee php -r 'echo PHP_VERSION;')"
echo "HTTP: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/)"
echo
echo "Terug naar v6: docker compose down; mv docker-compose.yml docker-compose.v7.yml;"
echo "  mv docker-compose.v6.yml docker-compose.yml; .env weg; database terugzetten uit de dump; docker compose up -d"
