FROM golang:latest

# cloudflare cfssl tool
# https://github.com/cloudflare/cfssl
RUN go get github.com/cloudflare/cfssl/cmd/cfssl \
    && go get github.com/cloudflare/cfssl/cmd/cfssljson

RUN apt-get update \
   && apt-get install -y -qqq zip \
   && curl -sfL https://install.goreleaser.com/github.com/goreleaser/nfpm.sh | sh \
   && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY src .

ENV BASEDIR=/src/

RUN chmod 755 run.sh \
    && mv run.sh /usr/local/bin/run

CMD ["false"]
