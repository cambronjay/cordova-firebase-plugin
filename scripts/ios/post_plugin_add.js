var helper = require("./helper");
var utils = require("../utils");
//var os = require('os');

module.exports = function(context) {
    var platforms = context.opts.cordova.platforms;
    if (platforms.indexOf("ios") !== -1) {
        var projectPath = utils.getProjectPath(context);
        helper.removeBuildPhaseScript(context, projectPath);
        helper.addBuildPhaseScript(context, projectPath);
    }
};