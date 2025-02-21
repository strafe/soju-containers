FROM --platform=$BUILDPLATFORM docker.io/library/node:alpine AS gamja-build
ARG GAMJA_REF=master
ADD https://codeberg.org/emersion/gamja.git#${GAMJA_REF} /src/
WORKDIR /src
RUN --mount=type=cache,target=/root/.npm \
	--mount=type=cache,target=/src/node_modules \
	--mount=type=cache,target=/src/.parcel-cache \
	npm install --include=dev && npm run build

FROM codeberg.org/emersion/kimchi AS gamja
COPY --from=gamja-build /src/dist /gamja
ADD kimchi-config /kimchi-config
