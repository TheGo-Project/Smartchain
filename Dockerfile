# Start from a base image with Go installed
FROM golang:1.22-alpine as builder

# Install build dependencies
RUN apk add --no-cache gcc musl-dev linux-headers git jq openssl curl

# Clone the specific version of Geth
RUN git clone https://github.com/ethereum/go-ethereum.git /go-ethereum && \
    cd /go-ethereum && \
    git checkout 2bd6bd01  # This hash corresponds to version 1.13.14

WORKDIR /go-ethereum

RUN go run build/ci.go install -static ./cmd/geth

# Setup the final image
FROM alpine:latest

# Install runtime dependencies including dos2unix and optionally bash
RUN apk add --no-cache ca-certificates jq dos2unix bash openssl curl

# Copy the Geth binary from the builder stage
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

# Copy genesis file and scripts
COPY genesis.json /root/genesis.json
COPY setup_and_start.sh /root/setup_and_start.sh
COPY entrypoint.sh /root/entrypoint.sh
COPY start_mining.js /root/start_mining.js

# Convert Windows line endings to Unix
RUN dos2unix /root/setup_and_start.sh /root/entrypoint.sh && \
    chmod +x /root/setup_and_start.sh /root/entrypoint.sh

# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp

# Set the entry point to run the setup script
ENTRYPOINT ["/bin/sh", "/root/setup_and_start.sh"]

