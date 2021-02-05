#!/bin/bash

sudo certbot certonly \
	--standalone \
	--http-01-port 8443 \
	--deploy-hook 'docker exec -it ngx nginx -s reload' \
	--cert-name objectiveceo.com \
	-d objectiveceo.com
