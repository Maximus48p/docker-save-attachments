FROM ubuntu:20.04

VOLUME /var/mail /config /output

ENV DEBIAN_FRONTEND noninteractive

ADD save-attachments.crontab /etc/cron.d/save-attachments
ADD save-attachments.sh /opt/save-attachments.sh

# install packages
RUN rm /etc/dpkg/dpkg.cfg.d/excludes \
    && apt-get update \
    && apt-get install -y libterm-readline-gnu-perl fetchmail maildrop ripmime \
    && apt-get clean && rm -fr /var/lib/apt/lists/*

RUN maildirmake /var/mail/working \
    && mkdir /var/mail/working/landing \
    && mkdir /var/mail/working/extracted \
    && echo "to /var/mail/working" > /root/.mailfilter \
    && touch /var/mail/save-attachments.log \
    && chmod 0644 /etc/cron.d/save-attachments

ADD docker-entrypoint.sh /opt/docker-entrypoint.sh
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["cron"]
