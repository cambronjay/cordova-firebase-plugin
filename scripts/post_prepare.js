#!/usr/bin/env node

'use strict';

var fs = require('fs');
var utils = require("./utils");
var config = fs.readFileSync('config.xml').toString();
var name = utils.getValue(config, 'name');
var IOS_DIR = 'platforms/ios';

var PLATFORM = {
  IOS: {
    dest: [
      IOS_DIR + '/' + name + '/Resources/GoogleService-Info.plist',
      IOS_DIR + '/' + name + '/Resources/Resources/GoogleService-Info.plist'
    ],
    src: [
      'GoogleService-Info.plist',
      IOS_DIR + '/www/GoogleService-Info.plist',
      'www/GoogleService-Info.plist'
    ]
  }
};

module.exports = function (context) {
  var platforms = context.opts.platforms;
  if (platforms.indexOf('ios') !== -1 && utils.directoryExists(IOS_DIR)) {
    console.log('Preparing Firebase for iOS');
    utils.copyKey(PLATFORM.IOS);
  }
};