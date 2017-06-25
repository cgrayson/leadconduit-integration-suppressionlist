const _                = require('lodash'),
      request          = require('request'),
      queryItem        = require('./query_item'),
      addItem          = require('./add_item'),
      helper           = require('./helper'),
      normalizeHeaders = helper.normalizeHeaders,
      validate         = helper.validate;


const wrap = (integration) => {
  return (vars, callback) => {
    let req;
    try {
      req = integration.request(vars);
    } catch (err) {
      return callback(err);
    }
    request(req, (err, resp, body) => {
      if (err) return callback(err);
      const res = {
        status: resp.statusCode,
        version: '1.1',
        headers: normalizeHeaders(resp.headers),
        body: body
      };
      let event;
      try {
        event = integration.response(vars, req, res);
      } catch (err) {
        return callback(err);
      }
      callback(null, event);
    })
  };
};

const query = wrap(queryItem);
const add = wrap(addItem);

const handle = (vars, callback) => {
  const queryVars = {
    list_names: [ vars.list_name ],
    values: vars.value,
    activeprospect: vars.activeprospect
  };

  query(queryVars, (err, queryEvent) => {
    if (err) return callback(err);
    const event = _.merge({}, queryEvent);
    const found = _.get(queryEvent, 'query_item.found');
    if (!found) {
      add(vars, (err, addEvent) => {
        if (err) return callback(err);
        _.merge(event, addEvent);
        event.outcome = 'success';
        callback(null, event);
      })
    } else {
      event.outcome = 'failure';
      event.reason = 'Duplicate';
      callback(null, event);
    }
  })
};

const requestVariables = () => {
  return [
    { name: 'list_name', description: 'SuppressionList List URL Name', required: true, type: 'string' },
    { name: 'value', description: 'Phone, email or other value to be added to the list', required: true, type: 'string' }
  ];
};

const responseVariables = () => {
  const vars = [
    { name: 'is_unique.outcome', type: 'string' },
    { name: 'is_unique.reason', type: 'string' }
  ];
  const queryVars = queryItem.response.variables().forEach((v) => {
    v.name = `is_unique.${v.name}`;
  });
  const addVars = addItem.response.variables().forEach((v) => {
    v.name = `is_unique.${v.name}`;
  });

  return vars.concat(queryVars).concat(addVars);
};

const name = 'Query and Add Missing Item';

module.exports = {
  name,
  handle,
  requestVariables,
  responseVariables,
  validate
};
