FROM --platform=$BUILDPLATFORM docker.io/library/golang:alpine AS kimchi-build
RUN --mount=type=cache,target=/var/cache/apk \
	apk -U add ca-certificates tzdata
ARG KIMCHI_REF=master
ADD https://codeberg.org/emersion/kimchi.git#${KIMCHI_REF} /src/
WORKDIR /src
ARG TARGETOS TARGETARCH TARGETVARIANT
RUN --mount=type=cache,target=/root/.cache/go-build \
	--mount=type=cache,target=/root/go/pkg/mod \
	<<EOF
	export GOOS=$TARGETOS GOARCH=$TARGETARCH
	if [ "$TARGETARCH" = arm ]; then
		export GOARM="${TARGETVARIANT##v}"
	fi
	go build
EOF

FROM scratch AS kimchi
COPY --from=kimchi-build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=kimchi-build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=kimchi-build /src/kimchi /kimchi
ENV PATH=/
CMD ["kimchi", "-config", "/kimchi-config"]

LABEL org.opencontainers.image.source="https://codeberg.org/emersion/soju-containers"
LABEL org.opencontainers.image.description="Web server"
