FROM --platform=$BUILDPLATFORM docker.io/library/golang:alpine AS kimchi-build
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
COPY --from=kimchi-build /src/kimchi /kimchi
ENV PATH=/
CMD ["kimchi", "-config", "/kimchi-config"]
