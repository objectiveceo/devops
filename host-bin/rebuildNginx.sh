#!/usr/bin/env bash

docker container rm ngx
docker create \
	--name ngx \
	--publish 80:80 \
	--publish 443:443 \
	--volume "${HOME}/objectiveceo/v2":"/objectiveceo/" \
	--volume "${HOME}/objectiveceo/ssl":"/objectiveceo/ssl" \
	--volume "/etc/letsencrypt/":"/etc/letsencrypt/" \
	--add-host=host.docker.internal:host-gateway \
	nginx:alpine
# docker cp ~/objectiveceo/objectiveceo.conf ngx:/etc/nginx/conf.d/
docker cp ~/objectiveceo/v2.objectiveceo.conf ngx:/etc/nginx/conf.d/
docker start ngx
