#!/usr/bin/env bash

docker container rm ngx
docker create \
	--name ngx \
	--publish 80:80 \
	--publish 443:443 \
	--volume "${HOME}/objectiveceo/":"/objectiveceo/" \
	--volume "/etc/letsencrypt/":"/etc/letsencrypt/" \
	--add-host=host.docker.internal:host-gateway \
	nginx:alpine
docker cp ~/objectiveceo/objectiveceo.conf ngx:/etc/nginx/conf.d/
docker cp ~/app/bethany.conf ngx:/etc/nginx/conf.d/
docker start ngx
