SERVICE=certs

all:: build

build:
	docker build -t $(SERVICE):latest .

default-domain: build
	@docker rm -f  $(SERVICE) 2>/dev/null || echo ""
	rm -rf certs
	mkdir -p certs
	docker run -it --name $(SERVICE) -v $$(pwd)/certs:/work  $(SERVICE):latest run raspberrypi localnet
	@docker rm -f  $(SERVICE) 2>/dev/null || echo ""
	docker run -it --name $(SERVICE) -v $$(pwd)/certs:/work  $(SERVICE):latest run "\*" localnet
	cp ./certs/localnet-raspberrypi-server.pem ./test/etc/server.crt
	cp ./certs/localnet-raspberrypi-server-key.pem ./test/etc/server.key

clean:
	rm -rf certs
	docker rmi -f $(SERVICE)