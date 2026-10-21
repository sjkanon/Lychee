# Projectlog (DJM-fork)

Nieuwste bovenaan.

## 2026-10-21

- `djm-image.yml` bouwt standaard de **legacy-variant** (`Dockerfile-legacy`: nginx + PHP-FPM 8.5 uit Sury). Die
  heeft de PHP-fix meteen bij opnieuw bouwen; FrankenPHP liep achter. Lokaal gebouwd: Lychee 7.11.1, PHP 8.5.12,
  embed aanwezig. Pushen alleen als PHP de nieuwste patch van zijn branch is (php.net). Compose wijst naar
  `ghcr.io/sjkanon/lychee-djm:latest-legacy`.
- Brug-image draait op de fotosite: PHP 8.4.27, healthy. `installeer.sh` omzeilt de `ContainerConfig`-bug van
  docker-compose 1.29 (host heeft nu ook Compose v2).
- Fork gemaakt na PHP2Shell (CVE-2026-109618/109619): de draaiende Lychee 6.6.9 had PHP 8.4.8 en er was nog
  geen gepatcht upstream-image.
- `v6-brug/Dockerfile`: bestaand v6-image met PHP 8.4.27 uit Sury, als tussenstap (`installeer.sh` zet hem op de host).
- `docker-compose.yml`, `.env.voorbeeld` en `MIGRATIE.md` voor de stap naar v7 (MariaDB 11.8, gelijk aan de
  huidige database).
- `djm-image.yml`: eigen image op ghcr, met controle op de PHP-versie.
