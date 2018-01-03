chalk = require 'chalk'
moment = require 'moment'

getStr = (args) ->
    (arg for arg in args).join ' '

getTimeStamp = () ->
    '[' + moment().format 'HH:mm:ss:SSS' + '] '

getStrWithTS = (args) ->
    getTimeStamp() + getStr args

log = () ->
    console.log getStr arguments

warn = () ->
    console.log chalk.yellow getStrWithTS arguments

err = () ->
    console.log chalk.redBright getStrWithTS arguments

debug = () ->
    console.log chalk.green getStr arguments

String::startsWith = (str) ->
    @trim().slice(0, str.length) is str

String::capitalize = () ->
    @[0].toUpperCase() + @slice(1).toLowerCase()

Array::last = () ->
    @[@length-1]

module.exports =
    log: log,
    warn: warn,
    err: err,
    debug: debug,
