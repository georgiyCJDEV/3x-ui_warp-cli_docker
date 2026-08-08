# ========================================================
# Stage: Source
# ========================================================

FROM alpine/git AS source
# Clone original github repo inside container
RUN git clone --depth 1 https://github.com/MHSanaei/3x-ui.git /src

# ========================================================
# Stage: Frontend (Vite)
# ========================================================
FROM --platform=$BUILDPLATFORM node:22-alpine AS frontend

COPY --from=source /src /src

WORKDIR /src/frontend
RUN npm ci && npm run build

# ========================================================
# Stage: Builder
# ========================================================
FROM golang:1.26-alpine AS builder
ARG TARGETARCH

RUN apk --no-cache --update add \
  build-base \
  gcc \
  curl \
  unzip \
  git

# Copy source from source stage
COPY --from=source /src /app/src
# Copy built frontend from previous stage
COPY --from=frontend /src/internal/web/dist /app/src/internal/web/dist

WORKDIR /app/src
ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-D_LARGEFILE64_SOURCE"
RUN go build -ldflags "-w -s" -o build/x-ui main.go
RUN ./DockerInit.sh "$TARGETARCH"

# ========================================================
# Stage: Final Image of 3x-ui
# ========================================================
FROM alpine
ENV TZ=Europe/Amsterdam
WORKDIR /app

RUN apk add --no-cache --update \
  ca-certificates \
  tzdata \
  fail2ban \
  bash \
  curl \
  openssl

COPY --from=builder /app/src/build/ /app/
COPY --from=builder /app/src/DockerEntrypoint.sh /app/
COPY --from=builder /app/src/x-ui.sh /usr/bin/x-ui
COPY --from=builder /app/src/internal/web/translation /app/internal/web/translation

# Configure fail2ban
RUN rm -f /etc/fail2ban/jail.d/alpine-ssh.conf \
    && cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local \
    && sed -i "s/^\[ssh\]$/&\nenabled = false/" /etc/fail2ban/jail.local \
    && sed -i "s/^\[sshd\]$/&\nenabled = false/" /etc/fail2ban/jail.local \
    && sed -i "s/#allowipv6 = auto/allowipv6 = auto/g" /etc/fail2ban/fail2ban.conf

RUN chmod +x \
  /app/DockerEntrypoint.sh \
  /app/x-ui \
  /usr/bin/x-ui

ENV XUI_IN_DOCKER="true"
ENV XUI_MAIN_FOLDER="/app"
ENV XUI_ENABLE_FAIL2BAN="true"
ENV XUI_DB_TYPE=""
ENV XUI_DB_DSN=""
EXPOSE 2053
VOLUME [ "/etc/x-ui" ]
CMD [ "./x-ui" ]
ENTRYPOINT [ "/app/DockerEntrypoint.sh" ]