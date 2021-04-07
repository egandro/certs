SERVICE=certs
DEFAULT_DOMAIN=my.localnet

all:: build

build:
	docker build -t $(SERVICE):latest .

default-domain: build
	@docker rm -f  $(SERVICE) 2>/dev/null || echo ""
	rm -rf certs
	mkdir -p certs
	docker run -it --name $(SERVICE) -v $$(pwd)/certs:/work  $(SERVICE):latest run raspberrypi $(DEFAULT_DOMAIN)
	@docker rm -f  $(SERVICE) 2>/dev/null || echo ""
	docker run -it --name $(SERVICE) -v $$(pwd)/certs:/work  $(SERVICE):latest run "\*" $(DEFAULT_DOMAIN)
	cp ./certs/my-localnet-wildcard-server.pem ./test/etc/server.crt
	cp ./certs/my-localnet-wildcard-server-key.pem ./test/etc/server.key
	tar czf certificates-$(DEFAULT_DOMAIN).tgz certs

clean:
	rm -rf certs
	docker rmi -f $(SERVICE)