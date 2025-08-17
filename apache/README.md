Very simple Docker image with Apache2 and Rebol served as a CGI script.

Build using this command:
```
docker build -t rebol-cgi-apache .
```

Files to edit:
* `conf/httpd.conf` - Main Apache configuration
* `start-rebol-cgi.r3` - Rebol Script to start the Docker image