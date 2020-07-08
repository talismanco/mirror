ARG GOLANG_VERSION

# === Stage #1 ===

# Use the official Alpine image to create our CA certificates.
# https://hub.docker.com/_/alpine
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:latest as certs-builder
RUN apk --update add ca-certificates

# === Stage #2 === 

# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:${GOLANG_VERSION}-alpine AS go-builder

# Create and change to the app directory.
WORKDIR /app

# Setup the Go environment flags for the subsequent build
ENV GO111MODULE=on\
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Retrieve application dependencies using go modules.
# Allows container builds to reuse downloaded dependencies.
COPY ./go.* ./
RUN go mod download
COPY ./ ./

# Build the binary.
# -mod=readonly ensures immutable go.mod and go.sum in container builds.
RUN go build \
  -mod=readonly \
  -v -o mirror ./cmd/mirror

# === Stage #3 === 

# Use the official scratch image for a lean production container.
# https://hub.docker.com/_/scratch
FROM scratch AS final

# Copy the CA certificates to the production image from the certs-builder stage.
COPY --from=certs-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Copy the binary to the production image from the go-builder stage.
COPY --from=go-builder /app/mirror /app/mirror
# Copy the configuation directory to the production image from the go-builder stage.
COPY --from=go-builder /app/config /app/config/

# Run the application on container startup.
CMD ["/app/mirror"]