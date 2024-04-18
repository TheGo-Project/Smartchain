# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.22-alpine as builder

RUN apk add --no-cache gcc musl-dev linux-headers git

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /go-ethereum/
COPY go.sum /go-ethereum/
RUN cd /go-ethereum && go mod download

ADD . /go-ethereum

RUN cd /go-ethereum && go run build/ci.go install -static ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates

COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

COPY genesis.json /root/genesis.json

EXPOSE 8545 8546 30303 30303/udp

VOLUME [ "/root/.ethereum" ]

ENTRYPOINT ["/bin/sh", "-c", "geth init /root/genesis.json && exec geth --networkid 4224 --http --http.addr 0.0.0.0 --http.port 8545 --http.api personal,eth,net,web3 --http.corsdomain 'https://remix.ethereum.org, *' --allow-insecure-unlock --nodiscover"]


ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
