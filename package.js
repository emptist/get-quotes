Package.describe({
  name: 'jk1968:get-quote',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'Meteor method for getting quotes from api.money.126.net',
  // URL to the Git repository containing the source code for this package.
  git: 'git@github.com:emptist/get-quotes.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.3.1');
  api.use(['coffeescript', 'http', 'mquandalle:jade'])
  api.addFiles('jk1968:get-quote.coffee');
});

Package.onTest(function(api) {
  //api.use('tinytest');
  api.use('jk1968:get-quote');
  api.addFiles('jk1968:get-quote-tests.js');
});
