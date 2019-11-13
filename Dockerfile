FROM debian:latest

# Install deps
RUN  apt-get update \
  && apt-get -y install --no-install-recommends \
    unzip wget ant maven openjdk-11-jdk git curl python \
  && rm -rf /var/lib/apt/lists/*

# Install caddy (a web server)
RUN cd /usr/local/bin \
  && wget https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta9/caddy2_beta9_linux_amd64 \
  && mv ./caddy2_beta9_linux_amd64 ./caddy \
  && chmod a+x ./caddy

# Download/build source
RUN git clone https://github.com/moovweb/vsaq.git /usr/src \
  && cd /usr/src \
  && ./do.sh install_deps \
  && ./do.sh build_prod

COPY client_side_only_impl/*.html /usr/src/client_side_only_impl/
COPY vsaq/static/maia.css /usr/src/vsaq/static/maia.css
COPY do.sh /usr/src/

RUN cd /usr/src \
  && ./do.sh build_prod \
  && mkdir -p /var/www \
  && mv /usr/src/build /var/www/html

EXPOSE 80/tcp

COPY server.json /var/www/server.json

WORKDIR /var/www/html

ENTRYPOINT [ "caddy" ]
CMD [ "run", "-config", "/var/www/server.json" ]