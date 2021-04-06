certutil -A -n "My Root CA" -t "TCu,Cu,Tu" -i etc/rootCA.pem -d sql:$HOME/.pki/nssdb
certutil -D -n "My Root CA" -d sql:$HOME/.pki/nssdb
