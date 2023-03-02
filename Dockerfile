# base go image
FROM golang:1.18-alpine as builder

RUN mkdir /app

COPY . /app

# Add the keys
ARG github_user=Sijibomi-stack
ENV github_user=$github_user
ARG github_personal_token=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
ENV github_personal_token=$github_personal_token

COPY /app /app/cmd/api

WORKDIR /app/cmd/api

RUN apk add git

RUN git config \
    --global \
    url."https://${github_user}:${github_personal_token}@github.com".insteadOf \
    "https://github.com"

RUN CGO_ENABLED=0 \
    GIT_TERMINAL_PROMPT=1 \
    GOARCH=amd64 \
    GOOS=linux \
    GO111MODULE=off \
    GOPRIVATE=github.com/Sijibomi-stack/memoryRoutes \
    go build -o cacheApp 

RUN chmod +x /app/cacheApp

FROM alpine:latest 

RUN mkdir /app

COPY --from=builder /app/cmd/api/cacheApp /app/cacheApp

ENTRYPOINT [ "/app/cacheApp" ]
