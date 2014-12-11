twelve = require 'twelve'

module.exports = twelve.env
    'mop:db:url': 'MOP_DB_URL'
    'mop:bus:url': 'MOP_BUS_URL'
    'mop:bus:channel':
        name: 'MOP_BUS_CHANNEL'
        required: false
