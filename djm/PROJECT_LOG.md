# Projectlog (DJM-fork)

Nieuwste bovenaan.

## 2026-10-21

- Fork gemaakt na PHP2Shell (CVE-2026-109618/109619): de draaiende Lychee 6.6.9 had PHP 8.4.8 en er was nog
  geen gepatcht upstream-image.
- `v6-brug/Dockerfile`: bestaand v6-image met PHP 8.4.27 uit Sury, als tussenstap (`installeer.sh` zet hem op de host).
- `docker-compose.yml`, `.env.voorbeeld` en `MIGRATIE.md` voor de stap naar v7 (MariaDB 11.8, gelijk aan de
  huidige database).
- `djm-image.yml`: eigen image op ghcr, met controle op de PHP-versie.
