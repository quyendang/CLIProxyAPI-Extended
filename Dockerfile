# ==============================
# Build stage
# ==============================
FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

ARG VERSION=railway
ARG COMMIT=railway
ARG BUILD_DATE=railway

RUN CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    go build \
    -ldflags="-s -w \
    -X 'main.Version=${VERSION}-plus' \
    -X 'main.Commit=${COMMIT}' \
    -X 'main.BuildDate=${BUILD_DATE}'" \
    -o ./CLIProxyAPIPlus \
    ./cmd/server/


# ==============================
# Runtime stage
# ==============================
FROM alpine:3.23

RUN apk add --no-cache \
    tzdata \
    ca-certificates

RUN mkdir -p \
    /CLIProxyAPI \
    /root/.cli-proxy-api

COPY --from=builder /app/CLIProxyAPIPlus /CLIProxyAPI/CLIProxyAPIPlus

COPY config.yaml /CLIProxyAPI/config.yaml

WORKDIR /CLIProxyAPI

ENV TZ=Asia/Ho_Chi_Minh

RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

EXPOSE 8317

CMD ["./CLIProxyAPIPlus"]
