# DJM: tijdelijke brug voor Lychee 6.6.9 (legacy-image, Debian 12 + Sury-PHP).
# Werkt alleen PHP bij binnen het bestaande image; Lychee zelf, volumes en compose blijven gelijk.
# Weg zodra de upgrade naar v7 gedaan is (zie ../MIGRATIE.md).
FROM lycheeorg/lychee@sha256:5f8c0aa029429d4c919bf7c4337f791851197f3adb2fff3cf023af6f8398fe0b
# De Sury-sleutel in dit image is verlopen; de actuele staat op packages.sury.org.
RUN curl -fsSL -o /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --only-upgrade 'php8.4-*' \
	&& rm -rf /var/lib/apt/lists/* \
	&& php -r 'exit(version_compare(PHP_VERSION, "8.4.27", ">=") ? 0 : 1);'
