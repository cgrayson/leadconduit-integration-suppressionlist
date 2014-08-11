mimecontent = require('mime-content')

request = (vars) ->
  list_ids = vars.list_ids.split(', ').join('|')

  url: "https://app.suppressionlist.com/exists/#{list_ids}/#{vars.list_item}"
  method: 'GET'
  headers:
    'Accept': 'application/json'
    'Authorization': "Basic #{new Buffer("X:#{vars.activeprospect.api_key}").toString('base64')}"

request.variables = ->
  [
    { name: 'activeprospect.api_key',    description: 'SuppressionList API Key',                   type: 'string', required: true },
    { name: 'list_ids',  description: 'SuppressionList List Id (comma separated)', type: 'string', required: true },
    { name: 'list_item', description: 'Item to be looked up (phone/email/etc.)',   type: 'string', required: true }
  ]


response = (vars, req, res) ->
  body = JSON.parse(res.body)

  if body.error?
    event = { outcome: 'error', reason: "SuppressionList error (#{res.status}) #{body.error}" }
  else
    event = JSON.parse(res.body)
    event.outcome = 'success'
    event.reason = null

  event


response.variables = ->
  [
    { name: 'query.outcome', type: 'string', description: 'Was the email sent? (\'success\' or \'error\')' },
    { name: 'query.reason', type: 'string', description: 'Error reason' },
    { name: 'query.list_item', type: 'string', description: 'the lookup item'},
    { name: 'query.found', type: 'boolean', description: 'is the lookup item found on any of the suppression lists?'},
    { name: 'query.exists_in_lists', type: 'list', description: 'list of suppression lists the item was found within'},
    { name: 'query.specified_lists', type: 'list', description: 'list of suppression lists that were queried'}
  ]


#
# Exports ----------------------------------------------------------------
#

module.exports =
  type: 'outbound'
  request: request
  response: response