FROM --platform=$BUILDPLATFORM docker.io/library/golang:alpine AS soju-build
RUN --mount=type=cache,target=/var/cache/apk \
	apk -U add build-base ca-certificates tzdata
ARG SOJU_REF=master
ADD https://codeberg.org/emersion/soju.git#${SOJU_REF} /src/
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
ARG KIMCHI_REF=master
ADD https://codeberg.org/emersion/kimchi.git#${KIMCHI_REF} /src/
WORKDIR /src
ARG TARGETOS TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
	--mount=type=cache,target=/root/go/pkg/mod \
	GOOS=$TARGETOS GOARCH=$TARGETARCH go build

FROM --platform=$BUILDPLATFORM docker.io/library/node:alpine AS gamja-build
ARG GAMJA_REF=master
ADD https://codeberg.org/emersion/gamja.git#${GAMJA_REF} /src/
WORKDIR /src
RUN --mount=type=cache,target=/src/node_modules \
	--mount=type=cache,target=/src/.parcel-cache \
	npm install --include=dev && npm run build

FROM scratch AS soju
COPY --from=soju-build /src/soju /src/sojudb /src/sojuctl /
COPY --from=soju-build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=soju-build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENV PATH=/
ENTRYPOINT ["soju"]
HEALTHCHECK CMD ["sojuctl", "help"]

FROM scratch AS gamja
COPY --from=kimchi-build /src/kimchi /kimchi
COPY --from=gamja-build /src/dist /gamja
ADD kimchi-config /kimchi-config
CMD ["/kimchi", "-config", "/kimchi-config"]
