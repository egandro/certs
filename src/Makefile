HOSTNAME=$(shell echo ${SERVERNAME} | sed -e 's/\*/wildcard/g')
FQDN=${HOSTNAME}.${DOMAIN}
FQDN_RAW=${SERVERNAME}.${DOMAIN}
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
INSTALL_BROWSER_CA=install-browser-certificate-$(CA)
UNINSTALL_BROWSER_CA=uninstall-browser-certificate-$(CA)
INSTALL_WINDOWS_CA=install-windows-$(CA).cmd
UNINSTALL_WINDOWS_CA=uninstall-windows-$(CA).cmd
WINDOWS_CA_ZIP=$(CA)-windows.zip

HOST_SERVER=$(PREFIX)-$(HOSTNAME)-server
HOST_SERVER_PEM=$(HOST_SERVER).pem
HOST_SERVER_CRT=$(HOST_SERVER).crt
HOST_SERVER_CSR=$(HOST_SERVER).csr
HOST_SERVER_KEY_PEM=$(HOST_SERVER)-key.pem
HOST_SERVER_KEY=$(HOST_SERVER).key

HOST_HAPROXY_PEM=$(PREFIX)-$(HOSTNAME)-haproxy.pem

NFPM_CA_YML=nfpm-$(CA).yml
NFPM_HOST_SERVER_YML=nfpm-$(HOST_SERVER).yml

.PHONY: all

all: check ca $(HOSTNAME)
	echo done

.PHONY: check

check:
	test -n "$(FQDN)"

.PHONY: ca $(HOSTNAME) $(WINDOWS_CA_ZIP) $(NFPM_CA_YML) $(NFPM_HOST_SERVER_YML)

ca: $(CA_PEM) $(WINDOWS_CA_ZIP) $(NFPM_CA_YML) $(NFPM_HOST_SERVER_YML)

$(HOSTNAME): $(HOST_SERVER_PEM) #$(HOST_HAPROXY_PEM)

$(CA_PEM):
	cfssl gencert -initca $(BASEDIR)ca.json | cfssljson -bare $(CA)
	rm $(CA_CSR)

$(HOST_JSON): $(BASEDIR)host.json.template
	sed -e "s/FQDN/$(FQDN_RAW)/g" < $(BASEDIR)host.json.template > $(HOST_JSON)

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
	rm $(INSTALL_WINDOWS_CA)
	rm $(UNINSTALL_WINDOWS_CA)

$(NFPM_CA_YML): $(CA_PEM) $(INSTALL_CA) $(UNINSTALL_CA) $(INSTALL_BROWSER_CA) $(UNINSTALL_BROWSER_CA)
	sed -e "s/PACKAGENAME/$(CA)/g" < $(BASEDIR)nfpm.yaml.ca.template > $(NFPM_CA_YML)
	sed -i "s/CA_FILE/$(CA)/g" $(NFPM_CA_YML)
	sed -i "s/POSTINSTALL/$(INSTALL_CA)/g" $(NFPM_CA_YML)
	sed -i "s/POSTREMOVE/$(UNINSTALL_CA)/g" $(NFPM_CA_YML)
	sed -i "s/INSTALL_BROWSER_CA/$(INSTALL_BROWSER_CA)/g" $(NFPM_CA_YML)
	sed -i "s/REMOVE_WINDOWS_CA/$(UNINSTALL_BROWSER_CA)/g" $(NFPM_CA_YML)
	sed -i "s/TIMESTAMP/$(NOW)/g" $(NFPM_CA_YML)
	nfpm -f $(NFPM_CA_YML) pkg --packager deb --target ./
	rm $(INSTALL_CA)
	rm $(UNINSTALL_CA)
	rm $(INSTALL_BROWSER_CA)
	rm $(UNINSTALL_BROWSER_CA)

$(NFPM_HOST_SERVER_YML): $(HOST_SERVER_PEM) $(HOST_SERVER_KEY_PEM)
	sed -e "s/PACKAGENAME/$(HOST_SERVER)/g" < $(BASEDIR)nfpm.yaml.ca.server.template > $(NFPM_HOST_SERVER_YML)
	sed -i "s/HOST_SERVER/$(HOST_SERVER)/g" $(NFPM_HOST_SERVER_YML)
	sed -i "s/TIMESTAMP/$(NOW)/g" $(NFPM_HOST_SERVER_YML)
	sed -i "s/FQDN/$(FQDN)/g" $(NFPM_HOST_SERVER_YML)
	nfpm -f $(NFPM_HOST_SERVER_YML) pkg --packager deb --target ./

.PHONY: $(HOST_SERVER_PEM)
$(HOST_SERVER_PEM): $(CA_PEM) $(CA_KEY_PEM) $(BASEDIR)cfssl.json $(HOST_JSON)
	cfssl gencert -ca $(CA_PEM) -ca-key $(CA_KEY_PEM) -config $(BASEDIR)cfssl.json -profile=server $(HOST_JSON) | cfssljson -bare $(HOST_SERVER)
	rm $(HOST_SERVER_CSR)
	rm $(HOST_JSON)

.PHONY: $(HOST_HAPROXY_PEM)
$(HOST_HAPROXY_PEM): $(CA_PEM) $(HOST_SERVER_PEM) $(HOST_SERVER_KEY_PEM)
	cat $(HOST_SERVER_PEM) $(HOST_SERVER_KEY_PEM) $(CA_PEM) > $(HOST_HAPROXY_PEM)

.PHONY: clean

clean:
	rm -f $(CA_PEM)
	rm -f $(CA_KEY_PEM)
	rm -f $(CA_CSR)
	rm -f $(HOST_SERVER_PEM)
	rm -f $(HOST_SERVER_KEY_PEM)
	rm -f $(HOST_SERVER_CSR)
	rm -f $(HOST_HAPROXY_PEM)
	rm -f $(HOST_JSON)
	rm -f $(INSTALL_CA)
	rm -f $(UNINSTALL_CA)
	rm -f $(INSTALL_BROWSER_CA)
	rm -f $(UNINSTALL_BROWSER_CA)
	rm -f $(INSTALL_WINDOWS_CA)
	rm -f $(UNINSTALL_WINDOWS_CA)
	rm -f $(WINDOWS_CA)