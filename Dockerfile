FROM --platform=${BUILDPLATFORM} golang:1.26-alpine3.24@sha256:3ad57304ad93bbec8548a0437ad9e06a455660655d9af011d58b993f6f615648 AS builder
RUN apk add --no-cache git
WORKDIR /workspace
COPY . .
ARG TARGETOS TARGETARCH TARGETVARIANT
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} go build -ldflags='-w -extldflags "-static"' -o webhook .

FROM cgr.dev/chainguard/static:latest
COPY --from=builder /workspace/webhook /usr/local/bin/webhook
ENTRYPOINT ["webhook"]
