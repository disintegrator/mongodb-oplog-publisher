antz = require 'antz'
async = require 'async'
logger = require('twelve').logger 'mop', 'watch'
MongoOplog = require 'mongo-oplog'
config = require '../config'

dbURL = config.get 'mop:db:url'
busURL = config.get 'mop:bus:url'
busChannel = config.get('mop:bus:channel') or 'objects'

oplog = MongoOplog dbURL

publisher = antz.publisher busURL, busChannel
publisher.on 'close', ->
    logger.error 'Publisher closed. Stopping'
    oplog.stop()
publisher.on 'error', (err) ->
    logger.error err
    oplog.stop()

opMap = {insert: 'create', update: 'update', delete: 'delete'}

watch = (op) ->
    logger.debug 'Watching %s on all namespaces', op
    oplog.on op, (doc) ->
        _id = if op in ['update'] then doc.o2?._id else doc.o?._id
        ns = doc.ns
        action = opMap[op]
        return unless ns and _id and action
        topic = "#{ns}.#{action}"
        payload = {_id: _id}
        publisher.publish topic, payload

watch 'insert'
watch 'update'
watch 'delete'

stopping = false
oplog.on 'error', (err) ->
    logger.error err
    stop(1) unless stopping
oplog.on 'end', ->
    logger.info 'Watch received end event'
    stop(1) unless stopping

stop = (code = 0) ->
    exiting = true
    async.parallel [
        (cb) -> publisher.close cb
        (cb) -> oplog.stop cb
    ], (err) ->
        logger.error err if err?
        setImmediate -> process.exit if err? then 1 else code


handleSignal = (signal) ->
    logger.info "Received signal #{signal}. Stopping."
    stop()
process.on 'SIGINT', handleSignal.bind null, 'SIGINT'
process.on 'SIGTERM', handleSignal.bind null, 'SIGTERM'
process.stdout.on 'error', -> stop 1

setImmediate -> oplog.tail -> logger.info 'Tailing oplog'
