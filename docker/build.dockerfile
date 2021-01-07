ARG GOLANG_VERSION

#######################
##    First Stage    ##
#######################

# Use the official Alpine image to create our CA certificates.
# https://hub.docker.com/_/alpine
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:latest as certs-builder
RUN apk --update add ca-certificates

########################
##    Second Stage    ##
########################

# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:${GOLANG_VERSION}-alpine AS go-builder

# Desired processor architecture
ARG ARCH=amd64
# Project HEAD commit hash
ARG COMMIT
# Name of the directory to output compiled binaries, 
# under the parent `./target/dist` directory.
ARG DIST=bin
# Desired operating system
ARG OS=linux
# Name of the project.
ARG PROJECT=mirror
# Indicates whether to build using static or dynamic linking
ARG STATIC_FLAG=-static
# Semantic version of the application.
ARG VERSION

# Absolute path to output compiled binaries.
ARG BIN=target/dist/${DIST}

# Create and change to the app directory.
WORKDIR /app

# Setup the Go environment flags for the subsequent build
ENV GO111MODULE=on \
  CGO_ENABLED=0 \
  GOOS=${OS} \
  GOARCH=${ARCH}

# Retrieve application dependencies using go modules.
# Allows container builds to reuse downloaded dependencies.
COPY ./go.* ./
RUN go mod download
COPY ./ ./

# Build the binary.
# -mod=readonly ensures immutable go.mod and go.sum in container builds.
RUN go build \
  -ldflags '-extldflags "-fno-PIC ${STATIC_FLAG}" -w -s -X release.version=${VERSION} -X release.commit=${COMMIT}' \
  -mod=readonly \
  -v -o ./${BIN}/${PROJECT} ./cmd/${PROJECT}

#######################
##    Third Stage    ##
#######################

# Use the official scratch image for a lean production container.
# https://hub.docker.com/_/scratch
FROM alpine:latest AS final

# Name of the directory to output compiled binaries, 
# under the parent `./target/dist` directory.
ARG DIST=bin
# Name of the project.
ARG PROJECT=mirror

# Absolute path to output compiled binaries.
ARG BIN=target/dist/${DIST}

# Copy the CA certificates to the production image from the certs-builder stage.
COPY --from=certs-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Copy the binary to the production image from the go-builder stage.
COPY --from=go-builder /app/${BIN}/${PROJECT} /app/${BIN}/${PROJECT}

ENTRYPOINT [ "/app/${BIN}/${PROJECT}" ]