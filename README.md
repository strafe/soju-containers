# soju-containers

Container manifests for [soju] and [gamja].

## Quick start

    docker compose build
    docker compose up -d
    docker compose exec soju sojuctl user create -username <username> -password <password> -admin

Then connect to http://localhost:8080 and login.

## Docker images

### [`codeberg.org/emersion/soju`][soju-img]

This image starts a soju instance reading its configuration from `/soju-config`.
The sojuctl utility is available in `PATH`.

### [`codeberg.org/emersion/gamja`][gamja-img]

This image serves the gamja webapp on port 80. By default, gamja will connect
to `ws://gamja-backend/socket`. The gamja configuration file can be customized
by mounting `/gamja-config.json`.

[soju]: https://soju.im/
[gamja]: https://codeberg.org/emersion/gamja
[soju-img]: https://codeberg.org/emersion/-/packages/container/soju/latest
[gamja-img]: https://codeberg.org/emersion/-/packages/container/gamja/latest
