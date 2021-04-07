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

## simple approach

  - <https://github.com/BenMorel/dev-certificates>