FROM amd64/ubuntu:20.04
WORKDIR /rebol
ENV REBOL_HOME=/rebol
ENV REBOL_VERSION 3.5.0

ADD https://github.com/Oldes/Rebol3/releases/download/$REBOL_VERSION/Rebol_${REBOL_VERSION}_x64-libc.gz .
RUN gunzip ./Rebol* && mv ./Rebol* /bin/rebol && chmod +x /bin/rebol

LABEL version="/$REBOL_VERSION"
LABEL description="REBOL (relative expression based object language) console."
LABEL maintainer="oldes.huhuman@gmail.com"

CMD "/bin/rebol"