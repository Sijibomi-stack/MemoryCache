# base go image
FROM golang:1.18-alpine as builder

RUN mkdir /app

COPY . /app

# Add the keys
ARG github_user
ENV github_user=$github_user
ARG github_personal_token
ENV github_personal_token=$github_personal_token

WORKDIR /app

RUN git config \
    --global \
    url."https://${github_user}:${github_personal_token}@@github.com".insteadOf \
    "https://github.com"

RUN CGO_ENABLED=0 go build -o cacheApp ./cmd/api

RUN chmod +x /app/cacheApp

FROM alpine:latest 

RUN mkdir /app

COPY --from=builder /app/cacheApp /app

CMD [ "/app/cacheApp" ]
