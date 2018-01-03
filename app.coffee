require 'coffeescript/register'
fs = require 'fs'
moment = require 'moment'
chalk = require 'chalk'
{ spawn } = require 'child_process'

{ log, warn, err, debug } = require './modules/general'
{ parse } = require './modules/parser'
{ transpile } = require './modules/transpile'
{ loadDictionary } = require './modules/dictionary'

input = output = null
args = process.argv.slice 2
for arg, index in args
    switch arg
        when '--input', '-i' then input = args[index+1]
        when '--output', '-o' then output = args[index+1]
        when '--show-code', '-sc' then showCode = true
        when '--show-structure', '-ss' then showStructure = true
        when '--run', '-r' then runWhenFinished = true

log()
console.log 'transpiling', chalk.green input, chalk.yellow '>>>', chalk.green output
log()

loadDictionary __dirname + '/test.dict.json'
source = fs.readFileSync __dirname + '/' + input, 'utf-8'
parsed = parse source
code = transpile parsed

if showStructure
    log()
    for key, value of parsed.directives
        log key, value

    for func in parsed.functions
        log()
        log 'function', func.name
        for line in func.instructions
            log '    ' + line.text
    log()

if showCode
    str = code.join '\n'
    log()
    log str

fs.writeFileSync __dirname + '/' + output, str, 'utf-8'
log()

if runWhenFinished
    child = spawn 'protractor', ['conf.js', '--specs', output]
    child.stdout.on 'data', (data) -> log data
    child.on 'close', (code, signal) ->
        debug 'finished running protractor (exit code ' + code + ')'
        log()