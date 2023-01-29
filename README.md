## Wildcard certicates
  - are supported
  - you need a domain name with >= 1 dot
    - OK: my.localnet
    - NOT OK: localnet

## DEB & RPM creation

  - https://nfpm.goreleaser.com/

## Testing
  - edit /etc/hosts and add "mywebserver.my.localnet" to 127.0.0.1
  - make build default-domain
  - cd test
  - make build run
  - openssl s_client -showcerts -connect mywebserver.my.localnet:8443 < /dev/null

## Install / Remove Root certificate
  - install: sudo dpkg -i certs/my-localnet-ca_*_all.deb
  - remove: sudo dpkg -r my-localnet-ca

## Windows Certstore

  - Win+R
  - certmgr.msc
  - idea how to create a msi file via Docker <https://github.com/dactivllc/docker-wix>, <https://stackoverflow.com/questions/13478297/silently-install-root-certificate-in-wix>
  - Windows CLI: https://superuser.com/questions/1506440/import-certificates-using-command-line-on-windows
  - <https://stackoverflow.com/questions/23869177/import-certificate-to-trusted-root-but-not-to-personal-command-line>
  - Windows
      - To add, use the command:
      - `certutil -addstore -f "ROOT" new-root-certificate.crt`
      - To remove, use the command:
      - `certutil -delstore "ROOT" serial-number-hex`

## Linux Installation
  - https://chromium.googlesource.com/chromium/src/+/master/docs/linux/cert_management.md
  - https://serverfault.com/questions/414578/certutil-function-failed-security-library-bad-database

## simple approach

  - <https://github.com/BenMorel/dev-certificates>
