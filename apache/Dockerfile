FROM httpd:2.4

# ---------- Build-time and runtime variables ----------
# Override REBOL_URL for your target architecture as needed.
ARG REBOL_URL=https://github.com/Oldes/Rebol3/releases/download/3.19.0/rebol3-core-linux-x64.gz
ENV REBOL_BIN=/usr/local/bin/rebol
ENV REBOL_HOME=/usr/local/rebol

# ---------- Tools to fetch Rebol ----------
RUN apt-get update \
 && apt-get install -y --no-install-recommends wget ca-certificates gzip \
 && rm -rf /var/lib/apt/lists/*


# ---------- Download and install Rebol3 ----------
RUN wget ${REBOL_URL}
RUN gunzip ./rebol3* && mv ./rebol3* "${REBOL_BIN}" && chmod +x "${REBOL_BIN}"


# ---------- Create Rebol modules directory ----------
# This ensures the directory "${REBOL_HOME}/.rebol/modules" exists.
RUN set -eux; \
    mkdir -p "${REBOL_HOME}/.rebol/modules"; \
    chown -R root:root "${REBOL_HOME}"


# ---------- Apache configuration for CGI ----------
RUN printf '\n\
PassEnv REBOL_BIN\n\
PassEnv REBOL_HOME\n\
<Directory "/usr/local/apache2/cgi-bin">\n\
    AllowOverride None\n\
    Options +ExecCGI\n\
    Require all granted\n\
</Directory>\n\
AddHandler cgi-script .r3\n' >> /usr/local/apache2/conf/httpd.conf


# ---------- Optional: copy example CGI scripts ----------
# COPY cgi-bin/ /usr/local/apache2/cgi-bin/
# RUN chmod +x /usr/local/apache2/cgi-bin/* || true

# ---------- Ports ----------
EXPOSE 80

# ---------- Start Apache and ensure CGI module is loaded ----------
CMD ["httpd-foreground", "-c", "LoadModule cgid_module modules/mod_cgid.so"]