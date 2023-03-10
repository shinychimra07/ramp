##
## Build
##

FROM golang:1.16-buster AS build
LABEL maintainer="Shiny Chimra <shinychimra07@gmail.com>"
WORKDIR /app

COPY go.mod .
RUN go mod download

COPY *.go ./

RUN go build -o /docker-simple-web-app

##
## Deploy
##
FROM gcr.io/distroless/base-debian10

WORKDIR /

COPY --from=build /docker-simple-web-app /docker-simple-web-app

USER nonroot:nonroot

ENTRYPOINT ["/docker-simple-web-app"]
