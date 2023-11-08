FROM docker.io/debian:bookworm-slim
MAINTAINER CYOSP <cyosp@cyosp.com>

RUN apt update \
    && apt install -y \
      --no-install-recommends \
      cron \
      nginx \
      supervisor

# Nginx
RUN rm -rf /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/sites-enabled/https.conf
RUN sed -i "s/user www-data;/user root;/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Crontab
ADD crontab /etc/cron.d/renewal
RUN crontab /etc/cron.d/renewal

EXPOSE 80

# Supervisor
RUN sed -i -e 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
COPY supervisor.conf /etc/supervisor/conf.d/https.conf
CMD /usr/bin/supervisord
