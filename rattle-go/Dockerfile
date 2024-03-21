FROM golang:1.21.5-alpine AS build

WORKDIR /

COPY . .

RUN go mod download

RUN go build -o ssl-cert-expiry main.go

FROM scratch

COPY --from=build /ssl-cert-expiry /usr/bin/ssl-cert-expiry

ENTRYPOINT [ "/usr/bin/ssl-cert-expiry" ]