# base go image
FROM golang:1.18-alpine as builder

ARG github_personal_token
ENV github_personal_token=${TOKEN}


RUN mkdir /app

COPY . /app

WORKDIR /app

RUN apk update && apk add --no-cache git

RUN git config --global url."https://Sijibomi-stack:${github_personal_token}@github.com".insteadOf "https://github.com"

ENV GOPRIVATE=github.com/Sijibomi-stack/memoryRoutes

RUN CGO_ENABLED=0 go build -buildvcs=false -o cacheApp ./cmd/api

RUN chmod +x /app/cacheApp

FROM alpine:latest

RUN mkdir /app

COPY --from=builder /app/cacheApp /app

CMD [ "/app/cacheApp" ]
