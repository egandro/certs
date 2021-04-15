## Wildcard certicates
  - are supported
  - you need a domain name with >= 1 dot
    - OK: my.localnet
    - NOT OK: localnet

## DEB & RPM creation

  - https://nfpm.goreleaser.com/

## Testing
  - openssl s_client -showcerts -connect raspberrypi.my.localnet:8443 < /dev/null

## Windows Certstore

  - Win+R
  - certmgr.msc
  - idea how to create a msi file via Docker <https://github.com/dactivllc/docker-wix>

## simple approach

  - <https://github.com/BenMorel/dev-certificates>
