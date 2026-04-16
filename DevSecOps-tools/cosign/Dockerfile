FROM alpine:3.20

RUN apk add --no-cache wget && \
    wget https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 && \
    chmod +x cosign-linux-amd64 && \
    mv cosign-linux-amd64 /usr/local/bin/cosign

WORKDIR /app
ENTRYPOINT ["cosign"]