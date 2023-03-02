# base go image
FROM golang:1.18-alpine as builder

RUN mkdir /app

COPY . /app

# Add the keysi
ARG github_user=Sijibomi-stack
ENV github_user=$github_user
ARG github_personal_token=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
ENV github_personal_token=$github_personal_token

WORKDIR /app

RUN apk add git

RUN git config \
    --global \
    url."https://${github_user}:${github_personal_token}@github.com".insteadOf \
    "https://github.com"

RUN CGO_ENABLED=0 \
    GIT_TERMINAL_PROMPT=1 \
    GOARCH=amd64 \
    GOOS=linux \
    go build -o -buildvcs=false cacheApp ./cmd/api

RUN chmod +x /app/cacheApp

FROM alpine:latest 

RUN mkdir /app

COPY --from=builder /app/cacheApp /app

ENTRYPOINT [ "/app/cacheApp" ]
