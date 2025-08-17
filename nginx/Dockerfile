FROM alpine:latest
WORKDIR /rebol
ENV REBOL_HOME=/rebol
ENV REBOL_VERSION=3.19.0

RUN apk add --no-cache nginx runit

ADD https://github.com/Oldes/Rebol3/releases/download/$REBOL_VERSION/rebol3-bulk-linux-x64-musl.gz .
RUN gunzip ./rebol* && mv ./rebol* /usr/local/bin/rebol && chmod +x /usr/local/bin/rebol


# Create directories
RUN mkdir -p /run/nginx /usr/share/nginx/html /etc/nginx/conf.d

# Copy NGINX config
#COPY conf/nginx.conf /etc/nginx/nginx.conf
#COPY conf.d/site.conf /etc/nginx/conf.d/site.conf

# runit service scripts
COPY app/run-nginx.sh /etc/service/nginx/run
COPY app/run-rebol.sh /etc/service/rebol/run
RUN chmod +x /etc/service/nginx/run /etc/service/rebol/run

# Entrypoint: start runsvdir to supervise services
COPY app/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose HTTP port
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

LABEL version="3.19"
LABEL description="Nginx with Rebol"
LABEL maintainer="oldes.huhuman@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/Oldes/Rebol-Docker"
