Very simple Docker image with NGINX and Rebol as a backend server.

Build using this command:
```
docker build -t rebol-nginx .
```

Files to edit:
* `start-rebol-cgi.r3` - Rebol Script to start the Docker image
* `conf/nginx.conf` - A minimal top-level NGINX configuration
* `conf/conf.d/site.conf` Example NGINX upstream config to reach Rebol in the same container
* `app/backend.r3` - Rebol HTTPd backend server configuration
* `app/public/*` - Static content