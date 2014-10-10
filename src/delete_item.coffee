mimecontent = require('mime-content')

request = (vars) ->
  values = vars.values.split(', ').join('|')

  url: "https://app.suppressionlist.com/lists/#{vars.list_id}/items"
  method: 'DELETE'
  headers:
    'Content-Type': 'application/json'
    'Accept': 'application/json'
    'Authorization': "Basic #{new Buffer("X:#{vars.activeprospect.api_key}").toString('base64')}"
  body:
    JSON.stringify(values: values)
request.variables = ->
  [
    { name: 'list_id',   description: 'SuppressionList List Id',                                  type: 'string', required: true },
    { name: 'values',    description: 'Item(s) to be removed from SuppressionList (comma separated)', type: 'string', required: true }
  ]


response = (vars, req, res) ->
  body = JSON.parse(res.body)

  if res.status != 200
    event = { outcome: 'error', reason: "SuppressionList error (#{res.status})" }
  else
    event = body
    event.outcome = 'success'
    event.reason = null

  delete_item: event

response.variables = ->
  [
    { name: 'delete_item.outcome', type: 'string', description: 'Was the email sent? (\'success\' or \'error\')' },
    { name: 'delete_item.reason', type: 'string', description: 'Error reason' },
    { name: 'delete_item.deleted', type: 'number', description: 'the number of items removed from the list'},
    { name: 'delete_item.rejected', type: 'number', description: 'the number of items not removed from the list'}
  ]


#
# Exports ----------------------------------------------------------------
#

module.exports =
  type: 'outbound'
  request: request
  response: response