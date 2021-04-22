FROM alpine:latest
WORKDIR /rebol
ENV REBOL_HOME=/rebol
ENV REBOL_VERSION 3.5.3

RUN wget -q https://github.com/Siskin-framework/Rebol/releases/download/$REBOL_VERSION/rebol3-bulk-x64-musl.gz
RUN gunzip ./rebol* && mv ./rebol* /bin/rebol && chmod +x /bin/rebol

LABEL version="3.5"
LABEL description="REBOL (relative expression based object language) console."
LABEL maintainer="oldes.huhuman@gmail.com"

CMD "/bin/rebol"