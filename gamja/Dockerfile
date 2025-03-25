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

FROM --platform=$BUILDPLATFORM docker.io/library/node:alpine AS gamja-build
ARG GAMJA_REF=master
ADD https://codeberg.org/emersion/gamja.git#${GAMJA_REF} /src/
WORKDIR /src
RUN --mount=type=cache,target=/root/.npm \
	--mount=type=cache,target=/src/node_modules \
	--mount=type=cache,target=/src/.parcel-cache \
	npm install --include=dev && npm run build

FROM scratch AS gamja
COPY --from=kimchi-build /src/kimchi /kimchi
COPY --from=gamja-build /src/dist /gamja
ADD kimchi-config /kimchi-config
CMD ["/kimchi", "-config", "/kimchi-config"]
