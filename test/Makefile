SERVICE=my-secure-webserver

all:: build

build:
	docker build -t $(SERVICE):latest .

run: build
	@docker rm -f  $(SERVICE) 2>/dev/null || echo ""
	@echo "update your /etc/hosts file!"
	@echo "browse to: https://raspberrypi.my.localnet"
	docker run --name $(SERVICE) -p 8443:443  $(SERVICE):latest

clean:
	rm -f certs
	docker rmi -f $(SERVICE)