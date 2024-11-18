FROM --platform=$BUILDPLATFORM docker.io/library/golang:alpine AS soju-build
RUN --mount=type=cache,target=/var/cache/apk \
	apk -U add build-base ca-certificates tzdata
ADD https://codeberg.org/emersion/soju.git /src/
WORKDIR /src
ARG TARGETOS TARGETARCH TARGETPLATFORM BUILDPLATFORM
RUN --mount=type=cache,target=/root/.cache/go-build \
	--mount=type=cache,target=/root/go/pkg/mod \
	<<EOF
	if [ "$TARGETPLATFORM" = "$BUILDPLATFORM" ]; then
		tags=""
		ldflags="-linkmode=external -extldflags=-static"
	else
		tags="moderncsqlite"
		ldflags=""
	fi
	ldflags="$ldflags -X codeberg.org/emersion/soju/config.DefaultPath=/soju-config"
	ldflags="$ldflags -X codeberg.org/emersion/soju/config.DefaultUnixAdminPath=/soju-admin.sock"
	GOOS=$TARGETOS GOARCH=$TARGETARCH \
		go build -o . -tags="$tags" -ldflags="$ldflags" ./cmd/...
EOF

FROM --platform=$BUILDPLATFORM docker.io/library/golang:alpine AS kimchi-build
# TODO: use Git URL once migrated off of sr.ht
ADD https://git.sr.ht/~emersion/kimchi/archive/master.tar.gz /src/
WORKDIR /src
ARG TARGETOS TARGETARCH
RUN tar --strip-components=1 -xf master.tar.gz
RUN --mount=type=cache,target=/root/.cache/go-build \
	--mount=type=cache,target=/root/go/pkg/mod \
	GOOS=$TARGETOS GOARCH=$TARGETARCH go build

FROM --platform=$BUILDPLATFORM docker.io/library/node:alpine AS gamja-build
ADD https://codeberg.org/emersion/gamja.git /src/
WORKDIR /src
RUN --mount=type=cache,target=/src/node_modules \
	--mount=type=cache,target=/src/.parcel-cache \
	npm install --include=dev && npm run build

FROM scratch AS soju
COPY --from=soju-build /src/soju /src/sojudb /src/sojuctl /
COPY --from=soju-build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=soju-build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/soju"]
HEALTHCHECK CMD ["/sojuctl", "help"]

FROM scratch AS gamja
COPY --from=kimchi-build /src/kimchi /kimchi
COPY --from=gamja-build /src/dist /gamja
ADD kimchi-config /kimchi-config
CMD ["/kimchi", "-config", "/kimchi-config"]
