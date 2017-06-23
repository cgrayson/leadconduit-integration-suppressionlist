const { Router } = require('express'),
      Client = require('suppressionlist');

module.exports =
  new Router()
    .use((req, res, next) => {
      res.locals.client = new Client(req.session.credential.token, process.env.NODE_ENV);
      next()
    })
    .get('/lists', (req, res, next) => {
      const client = res.locals.client;
      client.getLists((err, lists) => {
        if (err) {
          if (err.statusCode)
            return res.status(err.statusCode).send({ error: err.message });
          else
            return next(err);
        }
        res.status(200).send(lists);
      })
    })
    .post('/ensure_list', (req, res, next) => {
      const client = res.locals.client;
      const name = req.body.name;
      const ttl = req.body.ttl;
      client.ensureList(name, ttl, (err, list) => {
        if (err) {
          if (err.statusCode)
            res.status(err.statusCode).send({ error: err.message });
          else
            next(err);
          return;
        }
        res.status(200).send(list);
      })
    });