require 'coffeescript/register'
fs = require 'fs'
chalk = require 'chalk'

{ log, warn, err, debug, runProtractor, showParsedStructure } = require './modules/general'
{ parse } = require './modules/parser'
{ transpile } = require './modules/transpile'
{ loadDictionary } = require './modules/dictionary'

input = output = null
args = process.argv.slice 2
if args.length is 0
    err 'no arguments provided, please refer to readme.org for usage\n'
    return -1

for arg, index in args
    switch arg
        when '--input', '-i' then input = args[index+1]
        when '--output', '-o' then output = args[index+1]
        when '--show-code', '-sc' then showCode = true
        when '--show-structure', '-ss' then showStructure = true
        when '--run', '-r' then runWhenFinished = true
        when '--headless', '-h' then runHeadless = true

if not input
    err 'no input provided\n'
    return -1

if not output
    output = input + '.js'

console.log '\ntranspiling', chalk.green input, chalk.yellow '>>>', chalk.green output, '\n'

source = fs.readFileSync __dirname + '/' + input, 'utf-8'
parsed = parse source
code = transpile parsed

fs.writeFileSync __dirname + '/' + output, code, 'utf-8'

if showStructure
    showParsedStructure parsed

if showCode
    log '\n' + code + '\n'

if runWhenFinished
    runProtractor output, __dirname, runHeadless
