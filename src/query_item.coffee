mimecontent = require('mime-content')

request = (vars) ->
  list_ids = vars.list_ids.split(', ').join('|')

  url: "https://app.suppressionlist.com/exists/#{list_ids}/#{vars.list_item}"
  method: 'GET'
  headers:
    'Content-Type': 'application/json'
    'Accept': 'application/json'
    'Authorization': "Basic #{new Buffer("#{vars.apikey}:X").toString('base64')}"

request.variables = ->
  [
    { name: 'apikey',    description: 'SuppressionList API Key',                   type: 'string', required: true },
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
    { name: 'outcome', type: 'string', description: 'Was the email sent? (\'success\' or \'error\')' },
    { name: 'reason', type: 'string', description: 'Error reason' },
    { name: 'list_item', type: 'string', description: 'the lookup item'},
    { name: 'found', type: 'boolean', description: 'is the lookup item found on any of the suppression lists?'},
    { name: 'exists_in_lists', type: 'list', description: 'list of suppression lists the item was found within'},
    { name: 'specified_lists', type: 'list', description: 'list of suppression lists that were queried'}
  ]


#
# Exports ----------------------------------------------------------------
#

module.exports =
  type: 'outbound'
  request: request
  response: response