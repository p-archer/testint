chalk = require 'chalk'
moment = require 'moment'
fs = require 'fs'
{ spawn } = require 'child_process'

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

String::toCamelCase = () ->
    @trim().split(' ')[0].toLowerCase() + @trim().split(' ')[1..].map((x) -> x.capitalize()).join('')

Array::last = () ->
    @[@length-1]

showParsedStructure = (parsed) ->
    log()
    for key, value of parsed.directives
        log key, value

    for func in parsed.functions
        log '\nfunction', func.name
        for line in func.instructions
            log '\t' + line.text
    log()

runProtractor = (output, cwd, headless) ->
    runCode = [
        'var testModule = require(\'./' + output + '\');'
        ''
        'testModule.run();'
        ]
    fs.writeFileSync cwd + '/test.runner.js', runCode.join('\n'), 'utf-8'

    targetConf = if not headless then 'chrome.conf.js' else 'headless.conf.js'
    child = spawn 'protractor', [targetConf, '--specs', cwd + '/test.runner.js']
    child.stdout.on 'data', (data) -> log data
    child.on 'close', (code, signal) ->
        debug 'finished running protractor (exit code ' + code + ')\n'

module.exports =
    log: log,
    warn: warn,
    err: err,
    debug: debug,
    runProtractor: runProtractor
    showParsedStructure: showParsedStructure
