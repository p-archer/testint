{ warn, debug } = require './general'

dictionary = {}

replaceVariable = (variable) ->
    dictionary[variable] or null

add = (key, value) ->
    dictionary[key] = value

load = (fileName) ->
    entries = require fileName
    for key, value of entries
        if not dictionary[key]
            dictionary[key] = value
        else
            warn 'conflicting dictionary entries for ' + key + ', kept original value'
    return

add 'planner/graph', '\'#plannerGraph\''

module.exports =
    replaceVariable: replaceVariable
    loadDictionary: load
