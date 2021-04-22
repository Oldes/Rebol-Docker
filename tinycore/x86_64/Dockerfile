FROM tatsushid/tinycore:11.0-x86_64
WORKDIR /rebol
ENV REBOL_HOME=/rebol
ENV REBOL_VERSION 3.5.0

#ADD https://github.com/Oldes/Rebol3/releases/download/$REBOL_VERSION/Rebol_${REBOL_VERSION}_x64-libc.gz .
#RUN sudo gunzip ./Rebol* && sudo mv ./Rebol* /bin/rebol && sudo chmod +x /bin/rebol
ADD https://github.com/Oldes/Rebol3/releases/download/3.2.0/Rebol_3.2.0.4.4 /bin/rebol


LABEL version="/$REBOL_VERSION"
LABEL description="REBOL (relative expression based object language) console."
LABEL maintainer="oldes.huhuman@gmail.com"

#CMD "/bin/rebol"