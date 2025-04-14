FROM amd64/alpine
WORKDIR /rebol
ENV REBOL_HOME=/rebol
ENV REBOL_VERSION=3.19.0

ADD https://github.com/Oldes/Rebol3/releases/download/$REBOL_VERSION/rebol3-bulk-linux-x64-musl.gz .
RUN gunzip ./rebol* && mv ./rebol* /bin/rebol && chmod +x /bin/rebol

LABEL version="3.19"
LABEL description="REBOL (relative expression based object language) console."
LABEL maintainer="oldes.huhuman@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/Oldes/Rebol-Docker"

CMD "rebol"