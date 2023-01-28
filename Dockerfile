FROM golang:latest

# cloudflare cfssl tool
# https://github.com/cloudflare/cfssl
RUN go install github.com/cloudflare/cfssl/cmd/cfssl@latest \
    && go install github.com/cloudflare/cfssl/cmd/cfssljson@latest 

RUN echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | tee /etc/apt/sources.list.d/goreleaser.list \
   && apt-get update \
   && apt-get install -y -qqq nfpm zip \
   && curl -sfL https://install.goreleaser.com/github.com/goreleaser/nfpm.sh | sh \
   && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY src .

ENV BASEDIR=/src/

RUN chmod 755 run.sh \
    && mv run.sh /usr/local/bin/run

CMD ["false"]
