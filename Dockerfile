# Stage 1: Build the Caddy binary for the target architecture
FROM --platform=$BUILDPLATFORM caddy:builder AS builder

# Set environment variables for cross-compilation
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/root/.cache \
    case "$TARGETPLATFORM" in \
    "linux/amd64") ARCH="amd64" ;; \
    "linux/arm64") ARCH="arm64" ;; \
    "linux/arm/v7") ARCH="arm" ;; \
    *) echo "Unsupported platform: $TARGETPLATFORM"; exit 1 ;; \
    esac && \
    XCADDY_ARCH=$ARCH xcaddy build \
    --with github.com/caddy-dns/cloudflare

# Stage 2: Use the custom Caddy binary in the final image
FROM --platform=$TARGETPLATFORM caddy:2.8-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["docker-proxy"]