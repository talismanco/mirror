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
  -v -o start ./cmd/app

# Download Compile Daemon, 
RUN go get github.com/githubnemo/CompileDaemon

# Build go binary, and run it via CompileDaemon.
ENTRYPOINT CompileDaemon -build="go build -mod=readonly -v -o start ./cmd/app/main.go" -command="./start"