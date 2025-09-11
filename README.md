# soju-containers

Container manifests for [soju] and [gamja].

## Quick start

    docker compose build
    docker compose up -d
    docker compose exec soju sojuctl user create -username <username> -password <password> -admin

Then connect to http://localhost:8080 and login.

### Quadlets

Quadlets provide a way for systemd to manage podman containers for you. They follow a similar format to docker-compose, but with INI syntax instead of YAML.

#### Install process for `soju/soju.container`

1. Make sure you're using a systemd based OS
2. Install podman
3. Put the above quadlet file as `$XDG_CONFIG_HOME/containers/systemd/soju.container`
4. Make a config file at `$XDG_CONFIG_HOME/soju/config`, and make directories `$XDG_DATA_HOME/db` and `$XDG_DATA_HOME/uploads`
5. `systemctl --user daemon-reload` to have systemd generate a service for the quadlet
6. `systemctl --user start soju.service` to start the service. Note that you do not need to enable it because the `[Install]` section of the quadlet file handles that.
7. run sojudb commands like `podman exec -it systemd-soju sojudb create-user username -admin`

Optional extra step:

8. If you want your containers to auto update, be sure to run `systemctl --user enable podman-auto-update`. The `AutoUpdate` directive in the quadlet file specifies how to auto update, but it doesn't actually happen unless you have this service enabled.

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
