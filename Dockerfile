FROM docker.io/library/golang:alpine AS soju-build
RUN --mount=type=cache,target=/var/cache/apk \
	apk -U add build-base
ADD https://codeberg.org/emersion/soju.git /src/
WORKDIR /src
RUN --mount=type=cache,target=/root/.cache/go-build \
	--mount=type=cache,target=/root/go/pkg/mod \
	go build -o . \
		-ldflags "-linkmode=external -extldflags=-static \
		-X codeberg.org/emersion/soju/config.DefaultPath=/soju-config \
		-X codeberg.org/emersion/soju/config.DefaultUnixAdminPath=/soju-admin.sock" \
		./cmd/...

FROM docker.io/library/golang:alpine AS kimchi-build
# TODO: use Git URL once migrated off of sr.ht
ADD https://git.sr.ht/~emersion/kimchi/archive/master.tar.gz /src/
WORKDIR /src
RUN tar --strip-components=1 -xf master.tar.gz
RUN --mount=type=cache,target=/root/.cache/go-build \
	--mount=type=cache,target=/root/go/pkg/mod \
	go build

# TODO: use latest node once this is fixed:
# https://github.com/parcel-bundler/parcel/issues/9926
FROM docker.io/library/node:22.6-alpine AS gamja-build
ADD https://codeberg.org/emersion/gamja.git /src/
WORKDIR /src
RUN --mount=type=cache,target=/src/node_modules \
	--mount=type=cache,target=/src/.parcel-cache \
	npm install --include=dev && npm run build

FROM scratch AS soju
COPY --from=soju-build /src/soju /src/sojudb /src/sojuctl /
CMD /soju -config /soju-config

FROM scratch AS gamja
COPY --from=kimchi-build /src/kimchi /kimchi
COPY --from=gamja-build /src/dist /gamja
ADD kimchi-config /kimchi-config
CMD /kimchi -config /kimchi-config
