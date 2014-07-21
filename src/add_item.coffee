mimecontent = require('mime-content')

request = (vars) ->
  values = vars.values.split(', ').join('|')

  url: "https://app.suppressionlist.com/#{vars.list_id}/items"
  method: 'POST'
  headers:
    'Content-Type': 'application/json'
    'Accept': 'application/json'
    'Authorization': "Basic #{new Buffer("X:#{vars.apikey}").toString('base64')}"
  body:
    values: values
request.variables = ->
  [
    { name: 'apikey',    description: 'SuppressionList API Key',                    type: 'string', required: true },
    { name: 'list_id',   description: 'SuppressionList List Id',                    type: 'string', required: true },
    { name: 'values',    description: 'Item(s) to be added to SuppressionList (comma separated)',     type: 'string', required: true }
  ]


response = (vars, req, res) ->
  body = JSON.parse(res.body)

  if res.status != 200
    event = { outcome: 'error', reason: "SuppressionList error (#{res.status})" }
  else
    event = JSON.parse(res.body)
    event.outcome = 'success'
    event.reason = null

  event

response.variables = ->
  [
    { name: 'outcome', type: 'string', description: 'Was the email sent? (\'success\' or \'error\')' },
    { name: 'reason', type: 'string', description: 'Error reason' },
    { name: 'accepted', type: 'number', description: 'the number of items added to the list'},
    { name: 'rejected', type: 'number', description: 'the number of items not added to the list'}
  ]


#
# Exports ----------------------------------------------------------------
#

module.exports =
  type: 'outbound'
  request: request
  response: response