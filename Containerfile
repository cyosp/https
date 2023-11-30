FROM docker.io/debian:bookworm-slim
MAINTAINER CYOSP <cyosp@cyosp.com>

RUN apt update \
    && apt install -y \
      --no-install-recommends \
      certbot \
      cron \
      gettext-base \
      logrotate \
      nginx \
      supervisor

# Nginx
RUN rm -rf /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/sites-enabled/https.conf
RUN sed -i "s/user www-data;/user root;/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Setup config
ADD setup-config.sh /usr/local/bin/setup-config.sh
RUN chmod +x /usr/local/bin/setup-config.sh
COPY domain-base.template /tmp
COPY domain-path-http.template /tmp
COPY domain-path.template /tmp

# Crontab
ADD crontab /etc/cron.d/https
RUN crontab /etc/cron.d/https

# Logrotate
ADD logrotate-certbot-renew /etc/logrotate.d/certbot-renew

# Supervisor
RUN sed -i -e 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
COPY supervisor.conf /etc/supervisor/conf.d/https.conf

EXPOSE 80
VOLUME ["/conf", "/etc/letsencrypt"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
