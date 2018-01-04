require 'require-cson'

{ warn, debug } = require './general'

dictionary = {}

replaceVariable = (variable) ->
    find(variable)

add = (key, value, target = dictionary) ->
    keys = key.split '.'
    if keys.length > 1
        newKeys = keys.slice 1
        newTarget = target[keys[0]]
        if not newTarget then newTarget = {}
        add newKeys.join('.'), value, newTarget
    else
        if target[key]
            warn 'conflicting dictionary entries for ' + key
        else
            target[key] = value

load = (fileName) ->
    entries = require fileName
    for key, value of entries
        add(key, value)
    debug 'loaded dictionary ' + fileName
    return

find = (key, target = dictionary) ->
    keys = key.split '.'
    if keys.length > 1
        newKeys = keys.slice 1
        newTarget = target[keys[0]]
        if newTarget then find newKeys.join('.'), newTarget else null
    else
        target[key] or null

module.exports =
    replaceVariable: replaceVariable
    loadDictionary: load
