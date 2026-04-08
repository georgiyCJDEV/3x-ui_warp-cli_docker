FROM ubuntu:24.04

RUN apt update && apt install -y curl \
    gnupg \
    lsb-release \
    jq \
    socat

# Add Cloudflare WARP repo
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] http://pkg.cloudflareclient.com/ jammy main" > /etc/apt/sources.list.d/cloudflare-client.list

RUN apt update && apt install -y cloudflare-warp \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# SOCKS port
EXPOSE 40000

ENTRYPOINT ["/app/entrypoint.sh"]