# base go image
FROM golang:1.18-alpine as builder

RUN mkdir /app

COPY . /app

WORKDIR /app

RUN apk update && apk add --no-cache git

RUN git config --global url."https://Sijibomi-stack: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@github.com".insteadOf "https://github.com"

ENV GOPRIVATE=github.com/Sijibomi-stack/memoryRoutes

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o cacheApp ./cmd/api

RUN chmod +x /app/cacheApp

FROM alpine:latest 

RUN mkdir /app

COPY --from=builder /app/cacheApp /app

CMD [ "/app/cacheApp" ]
