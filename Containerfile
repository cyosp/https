FROM nginx

RUN apt update \
    && apt install -y \
      --no-install-recommends \
      cron

ADD crontab /etc/cron.d/renewal
RUN chmod 0644 /etc/cron.d/renewal \
      && crontab /etc/cron.d/renewal

ADD entrypoint-wrapper.sh /
RUN chmod +x /entrypoint-wrapper.sh

ENTRYPOINT ["/entrypoint-wrapper.sh"]

# Have to reset CMD since it gets cleared when we set ENTRYPOINT
CMD ["nginx", "-g", "daemon off;"]
