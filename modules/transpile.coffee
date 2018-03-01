{ warn, err, debug } = require './general'
{ replaceVariable, loadDictionary } = require './dictionary'

transpile = (test) ->
    code = []
    add = pushCode(code)

    if test.directives.dictionaries
        loadDictionaries test.directives.dictionaries.split ','

    if test.directives.modules
        for mod in test.directives.modules.split ','
            words = mod.trim().split ' '
            if words.length is 1
                add 'var ' + words[0].replace(/\./g, ' ').toCamelCase() + ' = require(\'./' + words[0] + '\');'
            if words.length is 3 and words[1] is 'as'
                add 'var ' + words[2] + ' = require(\'./' + words[0] + '\');'
        add ''

    add 'function run() {'
    add '\tdescribe(\'' + test.directives.title + '\', () => {'
    for func in test.functions when func.instructions.length > 0 and func.type is 'test'
        add '\t\t' + 'it(\'' + func.name + '\', () => {'
        for instruction in func.instructions
            add '\t\t\t' + toCode instruction
        add '\t\t});'
    add '\t});'
    add '}'

    exports = ['run']
    for func in test.functions when func.instructions.length > 0 and func.type is 'func'
        [ name, params ] = func.name.match(/(.+)\((.*)\)/)[1..2]
        func.name = name.toCamelCase()
        func.variables = params.split(',').map((x) => x.trim())
        add ''
        add 'function ' + func.name + '(' + func.variables.join(', ') + ') {'
        for instruction in func.instructions
            add '\t' + toCode instruction
        add '}'
        exports.push func.name

    if exports.length > 0
        add ''
        add 'module.exports = {'
        for entry in exports
            add '\t' + entry + ': ' + entry + ','
        add '};'
        add ''

    return code.join '\n'

loadDictionaries = (dicts) ->
    for dict in dicts
        loadDictionary dict.trim()

pushCode = (code) ->
    return (str) -> code.push(str)

toCode = (instruction) ->
    text = instruction.text.trim()

    if /^load \S+$/.test text
        return 'browser.get(\'' + text.slice(5).trim() + '\');'

    if /^click \(.+\)$/.test text
        target = getTarget text.slice 6
        return 'element(' + target + ').click();' if target?

    if /^expect \(.+\) to (not )?be \S+$/.test text
        target = getTarget text.slice 7
        isNot = / to not be /.test text
        toBe = text.match(/to (not )?be (\w+)/)[2]
        return 'element(' + target + ').is' + toBe.capitalize() + '();' if target?

    if /^input \(.+\) text .+$/.test text
        target = getTarget text.slice 6
        text = text.match(/input \(.+?\) text (.+)$/)[1]
        return 'element(' + target + ').sendKeys(' + text + ');' if target?

    if /^wait \S+$/.test text
        timeStr = text.match(/wait (\S+)$/)[1]
        switch timeStr.slice -1
            when 's' then time = +timeStr.slice(0, -1) * 1000
            when 'm' then time = +timeStr.slice(0, -1) * 60000
            else time = +timeStr
        return 'browser.driver.sleep(' + time + ');'

    if /^call \(.+\)( from \(.+?\))?( with \(.+\))$/.test text
        name = text.match(/call \((.+?)\)/)[1].toCamelCase()
        if /^call \(.+\) from \(.+?\)/.test text
            mod = text.match(/from \((.+?)\)/)[1]
            name = mod.replace(/\./g, ' ').toCamelCase() + '.' + name
        params = text.match(/call \(.+?\)( from \(.+?\))? with \((.+)\)/)
        if params then params = params[2] else params = ''
        return '' + name + '(' + params + ');'

    warn 'unknown or invalid #' + instruction.line + ': ' + text
    '//' + text

getTarget = (str) ->
    target = str.match(/^\((.+)\)/)[1]
    if target.startsWith '@'
        variable = replaceVariable target.slice 1
        if not variable
            err 'variable ' + target + ' not found in dictionary'
            return null
        else
            target = variable

    withModel = target.startsWith 'model'
    withText = /' with text '/.test target

    if withModel
        model = target.slice 6
        return 'by.model(\'' + model + '\')'

    element = target.match(/'(.+?)'/)[1]
    if withText
        text = target.match(/with text '(.+?)'/)[1]
        return 'by.cssContainingText(\'' + element + '\', \'' + text + '\')'

    return 'by.css(\'' + element + '\')'

module.exports =
    transpile: transpile
