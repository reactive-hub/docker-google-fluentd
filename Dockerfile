FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive
ENV GOOGLE_FLUENTD_VERSION 1.3.1-1

RUN set -x \
    && apt-get update -qq \
    && apt-get install -qq --no-install-recommends curl ca-certificates adduser \
    && curl -sSL "https://repo.stackdriver.com/wheezy.list" -o /etc/apt/sources.list.d/stackdriver.list \
    && ( curl -sSL https://app.stackdriver.com/RPM-GPG-KEY-stackdriver | apt-key add - ) \
    && apt-get update -qq \
    && apt-get install -qq --no-install-recommends google-fluentd=${GOOGLE_FLUENTD_VERSION} google-fluentd-catch-all-config \
    && apt-get remove -qq --auto-remove curl adduser \
    && apt-get clean -qq \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /var/log

ENTRYPOINT ["/entrypoint.sh"]
CMD ["google-fluentd"]
