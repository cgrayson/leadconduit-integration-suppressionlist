_ = require('lodash')
helper = require('./helper')

request = (vars) ->
  listNames = helper.getListUrlNames(vars)
  values = helper.getValues(vars).join('|')
  baseUrl = helper.getBaseUrl()

  url: "#{baseUrl}/exists/#{listNames}/#{values}"
  method: 'GET'
  headers: helper.getRequestHeaders(vars.activeprospect.api_key, false)

request.variables = ->
  [
    { name: 'list_names',  description: 'SuppressionList List URL Names (comma separated)', required: true, type: 'string' }
    { name: 'values', description: 'Phone, email or other values to be looked up (comma separated)',   required: true, type: 'string' }
  ]


response = (vars, req, res) ->
  event = helper.parseResponse(res)

  if event.exists_in_lists?
    event.found_in = event.exists_in_lists
    delete event.exists_in_lists

    event.added_at = _.last(_.sortBy(event.entries, 'added_at')).added_at
    delete event.entries

  query_item: event


response.variables = ->
  [
    { name: 'query_item.outcome', type: 'string', description: 'Was SuppressionList response data appended?' }
    { name: 'query_item.reason', type: 'string', description: 'Error reason' }
    { name: 'query_item.found', type: 'boolean', description: 'Is the lookup item found on any of the suppression lists?' }
    { name: 'query_item.found_in', type: 'array', description: 'List of suppression lists the item was found within' }
    { name: 'query_item.added_at', type: 'time', description: 'Most recent timestamp the found query item was added at' }
  ]


#
# Exports ----------------------------------------------------------------
#

module.exports =
  type: 'outbound'
  validate: helper.validate
  request: request
  response: response
