assert = require('chai').assert
integration = require('../src/delete_item')

describe 'Delete List Item', ->

  describe 'Request', ->
    request = null

    beforeEach ->
      request = integration.request(activeprospect: {api_key: '1234'}, list_id: 'things', values: 'taylor@activeprospect.com')

    it 'should have url', ->
      assert.equal 'https://app.suppressionlist.com/lists/things/items/taylor@activeprospect.com', request.url

    it 'should be delete', ->
      assert.equal 'DELETE', request.method


  describe 'Response', ->
    it 'should parse JSON body', ->
      vars = {}
      req = {}
      res =
        status: 200,
        headers:
          'Content-Type': 'application/json; charset=utf-8'
        body: """
              {
              "outcome": "success",
              "deleted": 2,
              "rejected": 0
              }
              """
      expected =
        delete_item:
          outcome: 'success'
          reason: null
          deleted: 2
          rejected: 0
      response = integration.response(vars, req, res)
      assert.deepEqual expected, response

    it 'should return error outcome on non-200 response status', ->
      vars = {}
      req = {}
      res =
        status: 400,
        headers:
          'Content-Type': 'application/json'
        body: """
              {
              "outcome":"error",
              "reason":"SuppressionList error (400)"
              }
              """
      expected =
        delete_item:
          outcome: 'error'
          reason: 'SuppressionList error (400)'
      response = integration.response(vars, req, res)
      assert.deepEqual expected, response

    it 'should return error outcome on 500/HTML response', ->
      vars = {}
      req = {}
      res =
        status: 500,
        headers:
          'Content-Type': 'text/html'
        body: """
              <!DOCTYPE html>
              <html>
              <head>
                <title>We're sorry, but something went wrong (500)</title>
                <style type="text/css">
                  body { background-color: #fff; color: #666; text-align: center; font-family: arial, sans-serif; }
                  div.dialog {
                    width: 25em;
                    padding: 0 4em;
                    margin: 4em auto 0 auto;
                    border: 1px solid #ccc;
                    border-right-color: #999;
                    border-bottom-color: #999;
                  }
                  h1 { font-size: 100%; color: #f00; line-height: 1.5em; }
                </style>
              </head>

              <body>
                <!-- This file lives in public/500.html -->
                <div class="dialog">
                  <h1>We're sorry, but something went wrong.</h1>
                </div>
              </body>
              </html>
              """
      expected =
        delete_item:
          outcome: 'error'
          reason: 'SuppressionList error (500) Possibly incorrect list_id'
      response = integration.response(vars, req, res)
      assert.deepEqual expected, response
