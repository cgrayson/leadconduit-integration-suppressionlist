const express = require('express'),
      session = require('express-session'),
      ui      = require('./lib/ui');


express()
  .use(session({ secret: 'dev', resave: false, saveUninitialized: true }))
  .use((req, res, next) => {
    if (!process.env.CRED) return next();
    req.session.credential = {
      token: process.env.CRED
    };
    next();
  })
  .use(ui)
  .listen(8080, () => {
    console.log('listening on 8080');
  });

