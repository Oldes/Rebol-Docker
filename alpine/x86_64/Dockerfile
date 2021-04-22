FROM alpine:3.13
WORKDIR /rebol
ENV REBOL_HOME=/rebol
ENV REBOL_VERSION 3.5.0

RUN wget -q https://github.com/Oldes/Rebol3/releases/download/$REBOL_VERSION/Rebol_${REBOL_VERSION}_x64-musl.gz && gunzip ./Rebol* && mv ./Rebol* /bin/rebol && chmod +x /bin/rebol

LABEL version="3.5"
LABEL description="REBOL (relative expression based object language) console."
LABEL maintainer="oldes.huhuman@gmail.com"

CMD "/bin/rebol"