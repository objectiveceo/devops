# How to run nginx on Docker

nginx runs very well on Docker, but there are some headaches when trying to communicate with the host network.  This should present a simple means of running nginx in a Docker container that will proxy to local ports.

## Setup

You can create an nginx container and copy the files into place before startup:

	docker create --name objectiveceo_nginx -p 80:80 nginx:alpine
	docker cp objectiveceo.conf objectiveceo_nginx:/etc/nginx/conf.d/

You can then start the container whenever you're ready:

	docker start objectiveceo_nginx

## Making changes

When the conf file is updated, it's trivial to copy it back into the running container:

	docker cp objectiveceo.conf objectiveceo_nginx:/etc/nginx/conf.d/

However, nginx won't notice the changes.  You could stop the container, prune it, and build it again, but it'd be much faster and easier to just tell nginx to reload:

	docker exec -it objectiveceo_nginx nginx -s reload
