HOSTNAME=$(shell echo ${NAME} | sed -e 's/\*/_asterix_/g')
FQDN=${HOSTNAME}.${DOMAIN}
FQDN_RAW=${NAME}.${DOMAIN}
PREFIX=$(shell echo ${DOMAIN} | sed -e 's/\./-/g')
BASEDIR := $(or ${BASEDIR},${BASEDIR},./)

NOW=$(shell date +%Y%m%d%H%M)

LOCAL_FOLDER=$(HOME)/.keys
SYSTEM_CERT_FOLDER=/usr/share/ca-certificates/$(FQDN)
SYSTEM_KEY_FOLDER=/etc/ssl/private

HOST_JSON=$(HOSTNAME).json

CA=$(PREFIX)-ca
CA_PEM=$(CA).pem
CA_CRT=$(CA).crt
CA_CSR=$(CA).csr
CA_KEY_PEM=$(CA)-key.pem
CA_KEY=$(CA).key

INSTALL_CA=install-root-$(CA).sh
UNINSTALL_CA=uninstall-root-$(CA).sh
INSTALL_BROWSER_CA=install-browser-$(CA).sh
UNINSTALL_BROWSER_CA=uninstall-browser-$(CA).sh
INSTALL_WINDOWS_CA=install-windows-$(CA).cmd
UNINSTALL_WINDOWS_CA=uninstall-windows-$(CA).cmd
WINDOWS_CA_ZIP=$(CA)-windows.zip

HOST_SERVER=$(PREFIX)-$(HOSTNAME)-server
HOST_SERVER_PEM=$(HOST_SERVER).pem
HOST_SERVER_CRT=$(HOST_SERVER).crt
HOST_SERVER_CSR=$(HOST_SERVER).csr
HOST_SERVER_KEY_PEM=$(HOST_SERVER)-key.pem
HOST_SERVER_KEY=$(HOST_SERVER).key

HOST_PEER=$(PREFIX)-$(HOSTNAME)-peer
HOST_PEER_PEM=$(HOST_PEER).pem
HOST_PEER_CRT=$(HOST_PEER).crt
HOST_PEER_CSR=$(HOST_PEER).csr
HOST_PEER_KEY_PEM=$(HOST_PEER)-key.pem
HOST_PEER_KEY=$(HOST_PEER).key

HOST_CLIENT=$(PREFIX)-$(HOSTNAME)-client
HOST_CLIENT_PEM=$(HOST_CLIENT).pem
HOST_CLIENT_CRT=$(HOST_CLIENT).crt
HOST_CLIENT_CSR=$(HOST_CLIENT).csr
HOST_CLIENT_KEY_PEM=$(HOST_CLIENT)-key.pem
HOST_CLIENT_KEY=$(HOST_CLIENT).key

HOST_HAPROXY_PEM=$(PREFIX)-$(HOSTNAME)-haproxy.pem

NFPM_YML=nfpm-$(CA).yml

.PHONY: all

all: check ca $(HOSTNAME) install-files
	echo done

.PHONY: check

check:
	test -n "$(FQDN)"

.PHONY: install-files

install-files: $(INSTALL_CA) $(UNINSTALL_CA) $(INSTALL_BROWSER_CA) $(UNINSTALL_BROWSER_CA) $(INSTALL_WINDOWS_CA) $(UNINSTALL_WINDOWS_CA) $(WINDOWS_CA_ZIP) $(NFPM_YML)

.PHONY: ca $(HOSTNAME)

ca: $(CA_PEM)
$(HOSTNAME): $(HOST_SERVER_PEM) $(HOST_PEER_PEM) $(HOST_CLIENT_PEM) $(HOST_HAPROXY_PEM)

$(CA_PEM): $(BASEDIR)ca.json
	cfssl gencert -initca $(BASEDIR)ca.json | cfssljson -bare $(CA)

$(INSTALL_CA): $(CA_PEM)
	sed -e "s/CA_FILE/$(CA)/g" < $(BASEDIR)install-cert-ca.template > $(INSTALL_CA)
	chmod 755 $(INSTALL_CA)

$(UNINSTALL_CA): $(CA_PEM)
	sed -e "s/CA_FILE/$(CA)/g" < $(BASEDIR)uninstall-cert-ca.template > $(UNINSTALL_CA)
	chmod 755 $(UNINSTALL_CA)

$(INSTALL_BROWSER_CA): $(CA_PEM)
	sed -e "s/CA_FILE/$(CA)/g" < $(BASEDIR)install-cert-ca-browser.template > $(INSTALL_BROWSER_CA)
	$(eval NAME := $(shell openssl x509 -in $(CA_PEM) -text | grep -e "CN =" | head -1 | sed -e 's/.*CN = //' ))
	sed -i "s/NAME/$(NAME)/g" $(INSTALL_BROWSER_CA)
	chmod 755 $(INSTALL_BROWSER_CA)

$(UNINSTALL_BROWSER_CA): $(CA_PEM)
	sed -e "s/CA_FILE/$(CA)/g" < $(BASEDIR)uninstall-cert-ca-browser.template > $(UNINSTALL_BROWSER_CA)
	$(eval NAME := $(shell openssl x509 -in $(CA_PEM) -text | grep -e "CN =" | head -1 | sed -e 's/.*CN = //' ))
	sed -i "s/NAME/$(NAME)/g" $(UNINSTALL_BROWSER_CA)
	chmod 755 $(UNINSTALL_BROWSER_CA)

$(INSTALL_WINDOWS_CA): $(CA_PEM)
	sed -e "s/CA_FILE/$(CA_PEM)/g" < $(BASEDIR)install-cert-ca-windows.template > $(INSTALL_WINDOWS_CA)
	sed 's/$$/\r/' -i $(INSTALL_WINDOWS_CA)

$(UNINSTALL_WINDOWS_CA): $(CA_PEM)
	sed -e "s/CA_FILE/$(CA_PEM)/g" < $(BASEDIR)uninstall-cert-ca-windows.template > $(UNINSTALL_WINDOWS_CA)
	$(eval CA_SERIAL := $(shell openssl x509 -noout -serial -in $(CA_PEM) | cut -d'=' -f2 | sed 's/../&:/g;s/:$$//' | sed -e 's/:/ /g'))
	sed -i "s/CA_SERIAL/$(CA_SERIAL)/g" $(UNINSTALL_WINDOWS_CA)
	sed -i 's/$$/\r/' $(UNINSTALL_WINDOWS_CA)

$(WINDOWS_CA_ZIP): $(CA_PEM) $(INSTALL_WINDOWS_CA) $(UNINSTALL_WINDOWS_CA)
	zip $(WINDOWS_CA_ZIP) $(CA_PEM) $(INSTALL_WINDOWS_CA) $(UNINSTALL_WINDOWS_CA)

$(HOST_JSON): $(BASEDIR)host.json.template
	sed -e "s/FQDN/$(FQDN_RAW)/g" < $(BASEDIR)host.json.template > $(HOST_JSON)

$(NFPM_YML): $(CA_PEM)
	sed -e "s/PACKAGENAME/$(PREFIX)/g" < $(BASEDIR)nfpm.yaml.template > $(NFPM_YML)
	sed -i "s/CA_FILE/$(CA)/g" $(NFPM_YML)
	sed -i "s/POSTINSTALL/$(INSTALL_CA)/g" $(NFPM_YML)
	sed -i "s/POSTREMOVE/$(UNINSTALL_CA)/g" $(NFPM_YML)
	sed -i "s/INSTALL_BROWSER_CA/$(INSTALL_BROWSER_CA)/g" $(NFPM_YML)
	sed -i "s/REMOVE_WINDOWS_CA/$(UNINSTALL_BROWSER_CA)/g" $(NFPM_YML)
	sed -i "s/TIMESTAMP/$(NOW)/g" $(NFPM_YML)
	nfpm -f $(NFPM_YML) pkg --packager deb --target ./

.PHONY: $(HOST_SERVER_PEM)
$(HOST_SERVER_PEM): $(CA_PEM) $(CA_KEY_PEM) $(BASEDIR)cfssl.json $(HOST_JSON)
	cfssl gencert -ca $(CA_PEM) -ca-key $(CA_KEY_PEM) -config $(BASEDIR)cfssl.json -profile=server $(HOST_JSON) | cfssljson -bare $(HOST_SERVER)

.PHONY: $(HOST_PEER_PEM)
$(HOST_PEER_PEM): $(CA_PEM) $(CA_KEY_PEM) $(BASEDIR)cfssl.json $(HOST_JSON)
	cfssl gencert -ca $(CA_PEM) -ca-key $(CA_KEY_PEM) -config $(BASEDIR)cfssl.json -profile=peer $(HOST_JSON) | cfssljson -bare $(HOST_PEER)

.PHONY: $(HOST_CLIENT_PEM)
$(HOST_CLIENT_PEM): $(CA_PEM) $(CA_KEY_PEM) $(BASEDIR)cfssl.json $(HOST_JSON)
	cfssl gencert -ca $(CA_PEM) -ca-key $(CA_KEY_PEM) -config $(BASEDIR)cfssl.json -profile=client $(HOST_JSON) | cfssljson -bare $(HOST_CLIENT)

.PHONY: $(HOST_HAPROXY_PEM)
$(HOST_HAPROXY_PEM): $(CA_PEM) $(HOST_SERVER_PEM) $(HOST_SERVER_KEY_PEM)
	cat $(HOST_SERVER_PEM) $(HOST_SERVER_KEY_PEM) $(CA_PEM) > $(HOST_HAPROXY_PEM)

.PHONY: install install-ca install-host

install: install-ca install-host

install-ca: $(CA_PEM) $(CA_KEY_PEM)
	mkdir -p $(SYSTEM_CERT_FOLDER)
	install -o root -m 644 $(CA_PEM) $(SYSTEM_CERT_FOLDER)/$(CA_CRT)
	install -o root -g ssl-cert -m 640 $(CA_CSR) $(SYSTEM_KEY_FOLDER)/$(CA_CSR)
	install -o root -g ssl-cert -m 640 $(CA_KEY_PEM) $(SYSTEM_KEY_FOLDER)/$(CA_KEY)

install-host: install-host-server install-host-peer install-host-client install-host-haproxy

.PHONY: install-host-server install-host-peer install-host-client install-host-haproxy

install-host-server: $(HOST_SERVER_PEM) $(HOST_SERVER_KEY_PEM)
	install -o root -m 644 $(HOST_SERVER_PEM) $(SYSTEM_CERT_FOLDER)/$(HOST_SERVER_CRT)
	install -o root -g ssl-cert -m 640 $(HOST_SERVER_KEY_PEM) $(SYSTEM_KEY_FOLDER)/$(HOST_SERVER_KEY)

install-host-peer: $(HOST_PEER_PEM) $(HOST_PEER_KEY_PEM)
	install -o root -m 644 $(HOST_PEER_PEM) $(SYSTEM_CERT_FOLDER)/$(HOST_PEER_CRT)
	install -o root -g ssl-cert -m 640 $(HOST_PEER_KEY_PEM) $(SYSTEM_KEY_FOLDER)/$(HOST_PEER_KEY)

install-host-client: $(HOST_CLIENT_PEM) $(HOST_CLIENT_KEY_PEM)
	install -o root -m 644 $(HOST_CLIENT_PEM) $(SYSTEM_CERT_FOLDER)/$(HOST_CLIENT_CRT)
	install -o root -g ssl-cert -m 640 $(HOST_CLIENT_KEY_PEM) $(SYSTEM_KEY_FOLDER)/$(HOST_CLIENT_KEY)

install-host-haproxy: $(HOST_HAPROXY_PEM)
	install -o root -m 640 $(HOST_HAPROXY_PEM) $(SYSTEM_KEY_FOLDER)/$(HOST_HAPROXY_PEM)

.PHONY: uninstall uninstall-ca uninstall-beast

uninstall: uninstall-ca uninstall-beast

uninstall-ca:
	rm $(SYSTEM_CERT_FOLDER)/$(CA_PEM)
	rm $(SYSTEM_KEY_FOLDER)/$(CA_KEY_PEM)

uninstall-beast:
	rm $(SYSTEM_CERT_FOLDER)/$(HOST_SERVER_PEM)
	rm $(SYSTEM_KEY_FOLDER)/$(HOST_SERVER_KEY_PEM)
	rm $(SYSTEM_CERT_FOLDER)/$(HOST_PEER_PEM)
	rm $(SYSTEM_KEY_FOLDER)/$(HOST_PEER_KEY_PEM)
	rm $(SYSTEM_CERT_FOLDER)/$(HOST_CLIENT_PEM)
	rm $(SYSTEM_KEY_FOLDER)/$(HOST_CLIENT_KEY_PEM)

install-local:
	mkdir -p $(LOCAL_FOLDER)
	cp $(HOST_SERVER_PEM) $(LOCAL_FOLDER)/server.crt
	cp $(HOST_SERVER_KEY_PEM) $(LOCAL_FOLDER)/server.key

.PHONY: clean

clean:
	rm -f $(CA_PEM)
	rm -f $(CA_KEY_PEM)
	rm -f $(CA_CSR)
	rm -f $(HOST_SERVER_PEM)
	rm -f $(HOST_SERVER_KEY_PEM)
	rm -f $(HOST_SERVER_CSR)
	rm -f $(HOST_PEER_PEM)
	rm -f $(HOST_PEER_KEY_PEM)
	rm -f $(HOST_PEER_CSR)
	rm -f $(HOST_CLIENT_PEM)
	rm -f $(HOST_CLIENT_KEY_PEM)
	rm -f $(HOST_CLIENT_CSR)
	rm -f $(HOST_HAPROXY_PEM)
	rm -f $(HOST_JSON)
	rm -f $(INSTALL_CA)
	rm -f $(UNINSTALL_CA)
	rm -f $(INSTALL_BROWSER_CA)
	rm -f $(UNINSTALL_BROWSER_CA)
	rm -f $(INSTALL_WINDOWS_CA)
	rm -f $(UNINSTALL_WINDOWS_CA)
	rm -f $(WINDOWS_CA)