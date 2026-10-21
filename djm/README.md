# DJM-aanpassingen aan Lychee

Deze fork (`sjkanon/Lychee`) is upstream Lychee plus alleen wat in deze map en in
`.github/workflows/djm-image.yml` staat. Zo blijft `git merge upstream/master` makkelijk.

- **Waarom een fork:** een eigen image bouwen als upstream nog niet bijgewerkt is (bijvoorbeeld na een
  PHP-beveiligingsfix), en de eigen opzet bij elkaar houden.
- **Image:** `ghcr.io/sjkanon/lychee-djm:latest-legacy` (nginx + PHP-FPM uit Sury), gebouwd door `djm-image.yml`
  uit `devel`, elke maandag opnieuw. Er wordt niets gepusht als PHP niet de nieuwste patch van zijn branch is.
  De FrankenPHP-variant kan ook (`variant=frankenphp`, tag `latest`).
- **Opzet:** [docker-compose.yml](docker-compose.yml) en [.env.voorbeeld](.env.voorbeeld).
- **Upgrade van v6:** [MIGRATIE.md](MIGRATIE.md). Tot dan: [v6-brug/](v6-brug/Dockerfile).
- **Bijhouden:** een watcher in de beheerrepo meldt via ntfy als upstream een release heeft, als deze fork
  achterloopt of als de PHP in het image te oud is.
- **Website:** de foto's op de verenigingssite komen uit een openbaar album via `/api/v2/Embed/<album-id>`.

Branches: `devel` (werk), `master` volgt upstream.
