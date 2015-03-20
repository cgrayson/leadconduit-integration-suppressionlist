mimecontent = require('mime-content')
helper = require('./helper')

request = (vars) ->
  values = helper.getValues vars

  url: "https://app.suppressionlist.com/lists/#{vars.list_id}/items/#{vars.values}"
  method: 'DELETE'
  headers: helper.getRequestHeaders()

request.variables = ->
  [
    { name: 'list_id', description: 'SuppressionList List Id', type: 'string' }
    { name: 'values', description: 'Item(s) to be removed from SuppressionList (comma separated)', type: 'string' }
  ]


response = (vars, req, res) ->
  delete_item: helper.parseResponse(res)

response.variables = ->
  [
    { name: 'delete_item.outcome', type: 'string', description: 'Was SuppressionList response data appended?' },
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
