var exec = require('cordova/exec');

exports.verifyPhone = function (number, timeOutDuration, success, error) {
  if (typeof timeOutDuration === 'function') {
    exec(timeOutDuration, success, "CordovaFirebasePlugin", "verifyPhone", [number]);
  } else {
    exec(success, error, "CordovaFirebasePlugin", "verifyPhone", [number, timeOutDuration]);
  }
};

exports.getInstanceId = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "getInstanceId", []);
};

exports.getFirebaseInstanceId = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "getFirebaseId", []);
};

exports.getFirebaseToken = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "getFirebaseToken", []);
};

exports.onApplicationNotificationOpen = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "onApplicationNotificationOpen", []);
};

exports.onFirebaseTokenRefresh = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "onFirebaseTokenRefresh", []);
};

exports.grantPermissions = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "grantPermissions", []);
};

exports.checkPermissions = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "checkPermissions", []);
};

exports.setApplicationBadgeNumber = function (number, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "setApplicationBadgeNumber", [number]);
};

exports.getApplicationBadgeNumber = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "getApplicationBadgeNumber", []);
};

exports.subscribeToFirebaseMsg = function (topic, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "subscribeToFirebaseMsg", [topic]);
};

exports.unsubscribeFromFirebaseMsg = function (topic, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "unsubscribeFromFirebaseMsg", [topic]);
};

exports.deregisterInstanceID = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "deregisterInstanceID", []);
};

exports.reportEvent = function (name, params, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "reportEvent", [name, params]);
};

exports.addCrashLog = function (message, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "addCrashLog", [message]);
};

exports.reportNonFatalCrash = function (message, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "reportNonFatalCrash", [message]);
};

exports.setCrashlyticsUserID = function (userId, success, error) {
    exec(success, error, "CordovaFirebasePlugin", "setCrashlyticsUserID", [userId]);
};

exports.setScreenName = function (name, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "setScreenName", [name]);
};

exports.setUserID = function (id, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "setUserID", [id]);
};

exports.setUserProperty = function (name, value, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "setUserProperty", [name, value]);
};

exports.implementRemoteConfig = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "implementRemoteConfig", []);
};

exports.getRemoteConfig = function (cacheExpirationSeconds, success, error) {
  var args = [];
  if (typeof cacheExpirationSeconds === 'number') {
    args.push(cacheExpirationSeconds);
  } else {
    error = success;
    success = cacheExpirationSeconds;
  }
  exec(success, error, "CordovaFirebasePlugin", "getRemoteConfig", args);
};

exports.getRemoteConfigValue = function (key, namespace, success, error) {
  var args = [key];
  if (typeof namespace === 'string') {
    args.push(namespace);
  } else {
    error = success;
    success = namespace;
  }
  exec(success, error, "CordovaFirebasePlugin", "getRemoteConfigValue", args);
};

exports.getFirebaseInfo = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "getFirebaseInfo", []);
};

exports.updateConfiguration = function (settings, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "updateConfiguration", [settings]);
};

exports.setFireBaseDefaults = function (defaults, namespace, success, error) {
  var args = [defaults];
  if (typeof namespace === 'string') {
    args.push(namespace);
  } else {
    error = success;
    success = namespace;
  }
  exec(success, error, "CordovaFirebasePlugin", "setFireBaseDefaults", args);
};

exports.startPerformanceTrace = function (name, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "startPerformanceTrace", [name]);
};

exports.traceIncrementCounter = function (name, counterNamed, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "traceIncrementCounter", [name, counterNamed]);
};

exports.stopPerformanceTrace = function (name, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "stopPerformanceTrace", [name]);
};

exports.enableAnalyticsReporting = function (enabled, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "enableAnalyticsReporting", [enabled]);
};

exports.enablePerformanceReporting = function (enabled, success, error) {
  exec(success, error, "CordovaFirebasePlugin", "enablePerformanceReporting", [enabled]);
};

exports.clearNotifications = function (success, error) {
  exec(success, error, "CordovaFirebasePlugin", "clearNotifications", []);
};