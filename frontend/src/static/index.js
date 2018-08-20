// pull in desired CSS/SASS files
require('./styles/styles.css');
require('../../node_modules/font-awesome/css/font-awesome.css');
require('../../node_modules/ace-css/css/ace.css');

// inject bundled Elm app into div#main
var Elm = require('../elm/Main');
Elm.Main.embed( document.getElementById('main'));
