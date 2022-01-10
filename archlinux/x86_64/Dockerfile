FROM archlinux:latest
WORKDIR /rebol
ENV REBOL_HOME=/rebol
ENV REBOL_VERSION 3.7.2

ADD https://github.com/Oldes/Rebol3/releases/download/3.7.2/rebol3-bulk-linux-x64.gz .
RUN gunzip ./rebol* && mv ./rebol* /bin/rebol && chmod +x /bin/rebol

LABEL version="/$REBOL_VERSION"
LABEL description="REBOL (relative expression based object language) console."
LABEL maintainer="oldes.huhuman@gmail.com"

CMD "/bin/rebol"