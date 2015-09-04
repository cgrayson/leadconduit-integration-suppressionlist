assert = require('chai').assert
helper = require('../src/helper')

describe 'Helper', ->

  describe 'Validate', ->

    it 'should require list_ids', () ->
      assert.equal helper.validate({}), 'list_ids must not be blank'

    it 'should require values', () ->
      assert.equal helper.validate(list_ids: 'foo'), 'values must not be blank'

    it 'should require values', () ->
      assert.equal helper.validate(list_ids: 'foo', values: ''), 'values must not be blank'

    it 'should require values', () ->
      assert.equal helper.validate(list_ids: 'foo', values: null), 'values must not be blank'

    it 'should be satisfied with list_ids and values', () ->
      assert.isUndefined helper.validate(list_ids: 'foo', values: 'bar@baz.com')

  describe 'Base URL', ->

    after ->
      process.env.NODE_ENV = 'test'

    it 'should get production url', ->
      process.env.NODE_ENV = 'production'
      assert.equal helper.getBaseUrl(), 'https://app.suppressionlist.com'

    it 'should get staging url', ->
      process.env.NODE_ENV = 'staging'
      assert.equal helper.getBaseUrl(), 'https://staging.suppressionlist.com'

    it 'should get development url', ->
      process.env.NODE_ENV = 'development'
      assert.equal helper.getBaseUrl(), 'http://suppressionlist.dev'

  describe 'Request Headers', ->
    headers = {}

    before ->
      headers = helper.getRequestHeaders('api_key')

    it 'should accept JSON', ->
      assert.equal headers.Accept, 'application/json'

    it 'should set authorization header', ->
      assert.equal headers.Authorization, 'Basic WDphcGlfa2V5'

    it 'should set content-type by default', ->
      assert.equal headers['Content-Type'], 'application/json'

    it 'should not set content-type when told not to', ->
      headers = helper.getRequestHeaders('api_key', false)
      assert.isUndefined headers['Content-Type']


