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

		if [ "$TARGETARCH" = arm ]; then
			arm_variant="${TARGETPLATFORM##*/v}"
		fi
	fi
	ldflags="$ldflags -X codeberg.org/emersion/soju/config.DefaultPath=/soju-config"
	ldflags="$ldflags -X codeberg.org/emersion/soju/config.DefaultUnixAdminPath=/soju-admin.sock"
	GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=$arm_variant \
		go build -o . -tags="$tags" -ldflags="$ldflags" ./cmd/...
EOF

FROM scratch AS soju
COPY --from=soju-build /src/soju /src/sojudb /src/sojuctl /
COPY --from=soju-build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=soju-build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENV PATH=/
ENTRYPOINT ["soju"]
HEALTHCHECK CMD ["sojuctl", "help"]
