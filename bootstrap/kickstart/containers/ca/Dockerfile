FROM golang:1.16.5-alpine3.13@sha256:96aa08f91b4f55098a8e44b1417c93ca31292d6235b094b56f16952ce7255fd6 as build
ENV STEP_VER="v0.15.16"

RUN apk add bash curl git make
RUN git clone -b ${STEP_VER} https://github.com/smallstep/cli.git /go/src/github.com/smallstep/cli

WORKDIR /go/src/github.com/smallstep/cli
RUN make bootstrap
RUN make build

FROM alpine@sha256:1775bebec23e1f3ce486989bfc9ff3c4e951690df84aa9f926497d82f2ffca9d
ENV CN="dev.gilman.io"

RUN addgroup -S app && adduser -S app -G app
RUN apk add openssl
COPY --from=build /go/src/github.com/smallstep/cli/bin/step /usr/bin/step
RUN mkdir -p /ca/consul
RUN mkdir -p /ca/control
RUN mkdir -p /ca/minio
RUN mkdir -p /ca/vault

WORKDIR /ca
COPY gen.sh .
RUN chmod +x gen.sh
RUN chown -R app:app /ca

USER app

ENTRYPOINT [ "/ca/gen.sh" ]