// require('ace-css/css/ace.css');

require('tachyons/css/tachyons.css');
require('tachyons-spacing/css/tachyons-spacing.css');
require('tachyons-flexbox/css/tachyons-flexbox.css');

require('font-awesome/css/font-awesome.css');

require('./styles.css');
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');
var app = Elm.Main.embed(mountNode);