# soju-containers

Container manifests for [soju] and [gamja].

## Quick start

    docker compose build
    docker compose up -d
    docker compose exec soju sojuctl user create -username <username> -password <password> -admin

Then connect to http://localhost:8080 and login.

[soju]: https://soju.im/
[gamja]: https://codeberg.org/emersion/gamja
