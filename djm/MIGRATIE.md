# Van Lychee 6 naar 7 (DJM)

Bron: <https://lycheeorg.dev/docs/administration/upgrade/>. Alleen het image-tag wijzigen werkt niet: v7 gebruikt
FrankenPHP op poort 8000 en andere paden, en weigert te starten met de oude volume-indeling.

## Vooraf

- Er is een image met gepatchte PHP (PHP2Shell, CVE-2026-109618/109619): 8.5.12 of hoger in de legacy-variant. Controle:
  `docker run --rm --entrypoint php <image> -r 'echo PHP_VERSION;'`
- Backup van database (`mariadb-dump --single-transaction lychee`) en van de map met `uploads`, `config`,
  `sym` en `docker-compose.yml`. Plus een Proxmox-backup van de VM.

## Stappen (in de map van de installatie)

1. `docker compose down` (v6).
2. `docker-compose.yml` vervangen door [docker-compose.yml](docker-compose.yml); `.env` maken uit
   [.env.voorbeeld](.env.voorbeeld). `APP_KEY` en `DB_PASSWORD` overnemen uit de v6-installatie
   (`config/.env` en de oude compose), anders zijn sessies en gegevens niet te lezen.
3. Mappen: `uploads/` blijft waar hij is. Nieuw: `mkdir -p logs tmp storage-app`, eigenaar `33:33` (www-data,
   net als in v6). `sym/` is in v7 niet meer nodig (laten staan tot alles werkt).
4. `docker compose pull && docker compose up -d`; `docker compose logs -f lychee` tot de migraties klaar zijn.
5. In de container: `php artisan lychee:recompute-album-sizes` en `php artisan lychee:recompute-album-stats`
   (of Instellingen → Onderhoud).
6. Controleren: inloggen, een album openen, een foto uploaden, en de embed:
   `curl https://<fotosite>/api/v2/Embed/<album-id>` geeft JSON voor een openbaar album.
7. Embed aanzetten in de instellingen als dat nog niet zo is (de route geeft 404 als hij uit staat).

## Terug naar v6

`docker compose down`, oude `docker-compose.yml` terugzetten, database terugzetten uit de dump
(de v7-migraties zijn niet omkeerbaar), `docker compose up -d`.

## Bekende problemen (uit de upstream-discussie)

- Rechten: het image controleert bij het starten de eigenaar van de mappen; zet `PUID`/`PGID` gelijk aan de
  eigenaar van `uploads/` (in v6: 33).
