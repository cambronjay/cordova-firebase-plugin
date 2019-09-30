var fs = require("fs");
var comment = "\"Firebase: Crashlytics\"";
var utils = require("../utils");
module.exports = {
    addBuildPhaseScript: function (context, xcodeProjectPath) {
        var xcode = context.requireCordovaModule("xcode");
        var xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();

        var s = '\\"'+'${SRCROOT}/' + utils.getAppName(context) + '/Plugins/cordova-firebase-plugin/Fabric.framework/run'+'\\"';
        var script = utils.bashEscape(s);

        var id = xcodeProject.generateUuid();

        xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[id] = {
            isa: "PBXShellScriptBuildPhase",
            buildActionMask: 2147483647,
            files: [],
            inputPaths: [],
            name: comment,
            outputPaths: [],
            runOnlyForDeploymentPostprocessing: 0,
            shellPath: "/bin/sh",
            shellScript: script,
            showEnvVarsInLog: 0
        };

        xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[id + "_comment"] = comment;

        for (var nativeTargetId in xcodeProject.hash.project.objects.PBXNativeTarget) {

            if (nativeTargetId.indexOf("_comment") !== -1) {
                continue;
            }

            var nativeTarget = xcodeProject.hash.project.objects.PBXNativeTarget[nativeTargetId];

            nativeTarget.buildPhases.push({
                value: id,
                comment: comment
            });
        }

        fs.writeFileSync(xcodeProjectPath, xcodeProject.writeSync());
    },

    removeBuildPhaseScript: function (context, xcodeProjectPath) {
        var xcode = context.requireCordovaModule("xcode");
        var xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();
        var buildPhases = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase;
        for (var buildPhaseId in buildPhases) {
            var buildPhase = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[buildPhaseId];
            var shouldDelete = false;
            if (buildPhaseId.indexOf("_comment") === -1) {
                shouldDelete = buildPhase.name && buildPhase.name.indexOf(comment) !== -1;
            }
            else {
                shouldDelete = buildPhaseId === comment;
            }
            if (shouldDelete) {
                delete buildPhases[buildPhaseId];
            }
        }

        var nativeTargets = xcodeProject.hash.project.objects.PBXNativeTarget;

        for (var nativeTargetId in nativeTargets) {

            if (nativeTargetId.indexOf("_comment") !== -1) {
                continue;
            }

            var nativeTarget = nativeTargets[nativeTargetId];

            nativeTarget.buildPhases = nativeTarget.buildPhases.filter(function (buildPhase) {
                return buildPhase.comment !== comment;
            });
        }

        fs.writeFileSync(xcodeProjectPath, xcodeProject.writeSync());
    }
};