var path = require("path");
var fs = require("fs");
var safePattern = /^[a-z0-9_\/\-.,?:@#%^+=\[\]]*$/i;
var safeishPattern = /^[a-z0-9_\/\-.,?:@#%^+=\[\]{}|&()<>; *']*$/i;

fs.ensureDirSync = function (dir) {
    if (!fs.existsSync(dir)) {
        dir.split(path.sep).reduce(function (currentPath, folder) {
            currentPath += folder + path.sep;
            if (!fs.existsSync(currentPath)) {
                fs.mkdirSync(currentPath);
            }
            return currentPath;
        }, '');
    }
};

module.exports = {
    bashEscape: function (arg) {
        if (safePattern.test(arg)) return arg;
        if (safeishPattern.test(arg)) return '"' + arg + '"';
        return "'" + arg.replace(/'+/g, function (val) {
            if (val.length < 3) return "'" + val.replace(/'/g, "\\'") + "'";
            return "'\"" + val + "\"'";
        }) + "'";
    },
    getAppName: function (context) {
        var ConfigParser = context.requireCordovaModule("cordova-lib").configparser;
        var config = new ConfigParser("config.xml");
        return config.name();
    },

    getPluginName: function () {
        return "cordova-firebase-plugin";
    },

    getProjectPath: function (context) {
        var appName = this.getAppName(context);
        return path.join("platforms", "ios", appName + ".xcodeproj", "project.pbxproj");
    },
    
    copyKey: function (platform) {
        for (var i = 0; i < platform.src.length; i++) {
            var file = platform.src[i];
            if (this.fileExists(file)) {
                try {
                    var contents = fs.readFileSync(file).toString();

                    try {
                        platform.dest.forEach(function (destinationPath) {
                            var folder = destinationPath.substring(0, destinationPath.lastIndexOf('/'));
                            fs.ensureDirSync(folder);
                            fs.writeFileSync(destinationPath, contents);
                        });
                    } catch (e) {
                        // skip
                    }
                } catch (err) {
                    console.log(err);
                }

                break;
            }
        }
    },

    getValue: function (config, name) {
        var value = config.match(new RegExp('<' + name + '(.*?)>(.*?)</' + name + '>', 'i'));
        if (value && value[2]) {
            return value[2]
        } else {
            return null
        }
    },

    fileExists: function (path) {
        try {
            return fs.statSync(path).isFile();
        } catch (e) {
            return false;
        }
    },

    directoryExists: function (path) {
        try {
            return fs.statSync(path).isDirectory();
        } catch (e) {
            return false;
        }
    }

};