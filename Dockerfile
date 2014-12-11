FROM debian:wheezy

MAINTAINER George Haidar <ghaidar0@gmail.com>

ENV MOP_DB_URL mongodb://localhost/local
ENV MOP_BUS_URL amqp://localhost
ENV MOP_BUS_CHANNEL objects

RUN set -e; \
    apt-get update; \
    apt-get install -y build-essential curl; \
    curl -sL https://deb.nodesource.com/setup | bash -; \
    apt-get install -y nodejs;
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g mongodb-oplog-publisher forever

CMD ["forever", "--minUptime", "1000", "--spinSleepTime", "1000", "/usr/bin/mop"]
