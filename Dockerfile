# base go image
FROM golang:1.18-alpine as builder

RUN mkdir /app

COPY . /app

WORKDIR /app


RUN CGO_ENABLED=0 go build -o cacheApp ./cmd/api

RUN chmod +x /app/cacheApp

FROM alpine:latest 

RUN apk add git

RUN mkdir /app

COPY --from=builder /app/cacheApp /app

CMD [ "/app/cacheApp" ]
