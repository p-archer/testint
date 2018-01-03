{ warn, err, debug } = require './general'
{ replaceVariable } = require './dictionary'

transpile = (test) ->
    code = []
    add = pushCode(code)

    add 'describe(\'' + test.directives.title + '\', () => {'
    for func in test.functions when func.instructions.length > 0
        add '\t' + 'it(\'' + func.name + '\', () => {'
        for instruction in func.instructions
            add '\t\t' + toCode instruction
        add '\t});'
        add ''
    add '});'

    return code

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

    if /^input \(.+\) text '.+'$/.test text
        target = getTarget text.slice 6
        text = text.match(/input \(.+?\) text '(.+)'/)[1]
        return 'element(' + target + ').sendKeys(\'' + text + '\');' if target?

    if /^wait \S+$/.test text
        timeStr = text.match(/wait (\S+)$/)[1]
        switch timeStr.slice -1
            when 's' then time = +timeStr.slice(0, -1) * 1000
            when 'm' then time = +timeStr.slice(0, -1) * 60000
            else time = +timeStr
        return 'browser.driver.sleep(' + time + ');'

    warn 'unknown or invalid #' + instruction.line + ': ' + text
    '//' + text

getTarget = (str) ->
    target = str.match(/^\((.+)\)/)[1]
    if target.startsWith '@'
        target = replaceVariable target.slice 1
        return null if not target

    withModel = target.startsWith 'model';
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
