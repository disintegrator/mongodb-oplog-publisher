MOP - mongodb-oplog-publisher
=============================

Simple daemon that tails a MongoDB oplog and publishes events to RabbitMQ.

## Install

        npm install -g mongodb-oplog-publisher

## Config

Configuration is done using environment variables.

        export MOP_DB_URL=mongodb://localhost/local
        export MOP_BUS_URL=amqp://localhost
        export MOP_BUS_CHANNEL=objects  # optional

## Run

        mop

        ## OR
        ## Install twelve for readable logging

        npm install -g twelve
        mop | tlog
