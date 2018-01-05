moment = require 'moment'

parse = (source) ->
    lines = source.split '\n'
    test =
        directives:
            title: 'test-' + moment().format 'YYYYMMDD'
        functions: []

    for line, index in lines
        if line.startsWith '#'
            directive = line.slice 1
            parts = directive.split '='
            key = parts[0].trim()
            value = parts[1].trim()
            test.directives[key] = value
            continue

        if line.startsWith 'function'
            test.functions.push
                name: line.slice 9
                instructions: []
                type: 'func'
            continue

        if line.startsWith 'test'
            test.functions.push
                name: line.slice 5
                instructions: []
                type: 'test'
            continue

        if line.startsWith '//'
            continue

        if line.startsWith 'end' # no function nesting yet
            continue

        if line.trim().length > 0 then test.functions.last().instructions.push
            text: line.trim()
            line: index

    return test

module.exports =
    parse: parse
