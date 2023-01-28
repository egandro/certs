SERVICE=certs
DEFAULT_DOMAIN=my.localnet

all:: build

pull:
	docker pull golang:latest

build:
	docker build -t $(SERVICE):latest .
	@docker rm -f  $(SERVICE) 2>/dev/null || echo ""

default-domain: build
	rm -rf certs
	mkdir -p certs
	@#docker run -it --name $(SERVICE) --user $$(id -u):$$(id -g) -v $$(pwd)/certs:/work  $(SERVICE):latest run raspberrypi $(DEFAULT_DOMAIN)
	docker run -it --name $(SERVICE) --user $$(id -u):$$(id -g) -v $$(pwd)/certs:/work  $(SERVICE):latest run "\*" $(DEFAULT_DOMAIN)
	cp ./certs/$$(echo $(DEFAULT_DOMAIN) | sed -e 's/\./-/g')-wildcard-server.pem ./test/etc/server.crt
	cp ./certs/$$(echo $(DEFAULT_DOMAIN) | sed -e 's/\./-/g')-wildcard-server-key.pem ./test/etc/server.key
	tar czf certificates-$(DEFAULT_DOMAIN).tgz certs

clean:
	rm -rf certs
	docker rmi -f $(SERVICE)
