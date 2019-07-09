var fs = require("fs");
var xcode = require("xcode");
var comment = "\"Fabric.io: Crashlytics\"";

module.exports = {
    addBuildPhaseScript: function (context, projectPath) {
        var project = xcode.project(projectPath);
        project.parseSync();
        var buildScript = '"\\"${PODS_ROOT}/Fabric/run\\""';
        var id = project.generateUuid();
        project.hash.project.objects.PBXShellScriptBuildPhase[id] = {
            isa: "PBXShellScriptBuildPhase",
            buildActionMask: 2147483647,
            files: [],
            inputPaths: [],
            name: comment,
            outputPaths: [],
            runOnlyForDeploymentPostprocessing: 0,
            shellPath: "/bin/sh",
            shellScript: buildScript,
            showEnvVarsInLog: 0
        };
        project.hash.project.objects.PBXShellScriptBuildPhase[id + "_comment"] = comment;
        for (var targetId in project.hash.project.objects.PBXNativeTarget) {
            if (targetId.indexOf("_comment") !== -1) {
                continue;
            }
            var target = project.hash.project.objects.PBXNativeTarget[targetId];
            target.buildPhases.push({
                value: id,
                comment: comment
            });
        }
        fs.writeFileSync(projectPath, project.writeSync());
    },

    removeBuildPhaseScript: function (context, projectPath) {
        var project = xcode.project(projectPath);
        project.parseSync();
        var phases = project.hash.project.objects.PBXShellScriptBuildPhase;
        for (var phaseId in phases) {
            var phase = project.hash.project.objects.PBXShellScriptBuildPhase[phaseId];
            var deleteComment = false;
            if (phaseId.indexOf("_comment") === -1) {
                deleteComment = phase.name && phase.name.indexOf(comment) !== -1;
            } else {
                deleteComment = phaseId === comment;
            }

            if (deleteComment) {
                delete phases[phaseId];
            }
        }
        var targets = project.hash.project.objects.PBXNativeTarget;
        for (var targetId in targets) {
            if (targetId.indexOf("_comment") !== -1) {
                continue;
            }
            var target = targets[targetId];
            target.buildPhases = target.buildPhases.filter(function (buildPhase) {
                return buildPhase.comment !== comment;
            });
        }
        fs.writeFileSync(projectPath, project.writeSync());
    }
};