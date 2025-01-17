FROM golang:1.11 as builder

WORKDIR /go/src/mikefarah/yq

# cache devtools
COPY ./scripts/devtools.sh /go/src/mikefarah/yq/scripts/devtools.sh
RUN ./scripts/devtools.sh

# cache vendor
COPY ./vendor/vendor.json /go/src/mikefarah/yq/vendor/vendor.json
RUN govendor sync

COPY . /go/src/mikefarah/yq

RUN CGO_ENABLED=0 make local build

# Choose alpine as a base image to make this useful for CI, as many
# CI tools expect an interactive shell inside the container
FROM andthensome/alpine-hugo-git-bash as production

COPY --from=builder /go/src/mikefarah/yq/yq /usr/bin/yq
RUN chmod +x /usr/bin/yq

ARG VERSION=none
LABEL version=${VERSION}

WORKDIR /workdir
