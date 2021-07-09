FROM golang:1.16.5-alpine3.13@sha256:96aa08f91b4f55098a8e44b1417c93ca31292d6235b094b56f16952ce7255fd6 as minio
ENV MINIO_VER="RELEASE.2021-06-17T00-10-46Z"

RUN apk add bash curl git make perl
RUN git clone -b ${MINIO_VER} https://github.com/minio/minio.git /go/src/github.com/minio/minio

WORKDIR /go/src/github.com/minio/minio
RUN make getdeps
RUN make build

FROM alpine@sha256:1775bebec23e1f3ce486989bfc9ff3c4e951690df84aa9f926497d82f2ffca9d

RUN addgroup -S app && adduser -S app -G app
COPY --from=minio /go/src/github.com/minio/minio/minio /usr/bin/minio

RUN mkdir -p /etc/minio.d
RUN mkdir /etc/minio.d/certs
RUN mkdir /data

RUN chown -R app:app /etc/minio.d
RUN chown -R app:app /data

USER app

ENTRYPOINT [ "/usr/bin/minio" ]