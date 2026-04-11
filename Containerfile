# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/aurora:beta AS raw

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

FROM quay.io/coreos/chunkah AS chunkah
ARG CHUNKAH_CONFIG_STR
RUN --mount=from=raw,src=/,target=/chunkah,ro \
    --mount=type=bind,target=/run/src,rw \
        chunkah build \
        --max-layers=448 \
        --compressed \
        --prune /sysroot/ > /run/src/out.ociarchive

FROM oci-archive:out.ociarchive
