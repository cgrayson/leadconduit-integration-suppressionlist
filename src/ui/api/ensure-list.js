const { Router } = require('express'),
      Client = require('suppressionlist');

module.exports =
  new Router()
    .post('/', (req, res, next) => {
      const apiKey = req.session.credential.token;
      const client = new Client(apiKey, process.env.NODE_ENV);
      const name = req.body.name;
      const ttl = req.body.ttl;
      client.ensureList(name, ttl, (err, list) => {
        if (err) {
          if (err.statusCode)
            res.status(err.statusCode).send({ error: err.message, reason: err.body });
          else
            next(err);
          return;
        }
        res.status(200).send(list);
      })
    });