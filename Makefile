SERVICE=certs
DEFAULT_DOMAIN=my.local
DEFAULT_CHROME_NAME=mycert

all:: build

pull:
	docker pull golang:latest

build:
	docker build -t $(SERVICE):latest .
	@docker rm -f  $(SERVICE) 2>/dev/null || echo ""

default-domain: build
	rm -rf certs
	mkdir -p certs
	docker run -it --name $(SERVICE) --user $$(id -u):$$(id -g) -v $$(pwd)/certs:/work  $(SERVICE):latest run "\*" $(DEFAULT_DOMAIN)
	cp ./certs/$$(echo $(DEFAULT_DOMAIN) | sed -e 's/\./-/g')-wildcard-server.pem ./test/etc/server.crt
	cp ./certs/$$(echo $(DEFAULT_DOMAIN) | sed -e 's/\./-/g')-wildcard-server-key.pem ./test/etc/server.key
	tar czf certificates-$(DEFAULT_DOMAIN).tgz certs

#sudo apt install libnss3-tools
default-install-chrome: default-uninstall-chrome
	certutil -d sql:$$HOME/.pki/nssdb -A -t "C,," -n $(DEFAULT_CHROME_NAME) -i ./certs/$$(echo $(DEFAULT_DOMAIN) | sed -e 's/\./-/g')-ca.pem

default-uninstall-chrome:
	certutil -d sql:$$HOME/.pki/nssdb -L -n $(DEFAULT_CHROME_NAME) || true
	certutil -d sql:$$HOME/.pki/nssdb -D -n $(DEFAULT_CHROME_NAME) || true

clean:
	rm -rf certs *.tgz
	docker rmi -f $(SERVICE)
