# Cordova Firebase Plugin
This plugin wraps the Firebase remote config, performance, analytics, crashlytics, messaging, and authentication SDK with an easy to use api and detailed documentation. Follow the below instructions for iOS setup and plugin use.

## Supported Cordova Versions
- cordova: `>=6.0.0 and <=8.1.2`
- cordova-ios: `>=4.0.0 and <=5.0.0`

## Plugin Dependency
- cordova-sqlite-storage: `>=3.2.1`

## Setup Firebase
1. Create a Firebase account if you don't already have one 
2. View [Firebase setup](https://support.google.com/firebase/answer/9326094?hl=en&ref_topic=6400762) on how to add an app. 
3. Add an ios app.
4. Register the app in step 1 of the prompt
5. Download the config file for later use. 
6. Skip step 3 and 4 of the prompt
7. Leave the browser open on step 5 and continue to the Project Setup below.

## Project Setup for the Plugin
Install the above plugin dependency if you don't already have it installed. Place your Firebase configuration file (GoogleService-Info.plist) into the root folder of your project. View [Firebase support](https://support.google.com/firebase/answer/7015592) for details on how to download the file if you did not download it in the above Firebase Setup.

```
- My Project/
    platforms/
    plugins/
    www/
    config.xml
    GoogleService-Info.plist   <--
    ...
```

## Install the Plugin
Install the plugin with this command:
```
cordova plugin add cordova-firebase-plugin --save
```
or for Ionic this command:
```
ionic cordova plugin add cordova-firebase-plugin
```
or add this to your config.xml: 
```
<plugin name="cordova-firebase-plugin" spec="1.1.4" />
```

## Build the app and it will be added to Firebase
1. Build your app and run it with Xcode on a conected device or simulator
2. Click the stop button on Xcode and then press the play button
3. The opened Firebase tab from the above Firebase Setup should pick up the app activation
4. If Firebase does not give a success message then uninstall the app from the simulator or connected device and then repeat steps 1-4

## Crashlytics Setup
1. Open Firebase Crashlytics in your browser after adding your app to Firebase successfully via the above app build process 
2. Click "Setup Crashlytics"
3. Select "No, Setup a new Firebase app
4. Click "Go to Crashlytics Docs"
5. Navigate back to the Firebase Crashlytics tab on your browser
6. Build your app and run it with Xcode on a connected device or simulator
7. Click the stop button on Xcode and then press the play button
8. The opened Firebase Crashlytics tab in your browser should pick up the app activation
9. If Crashlytics does not give a success message then uninstall the app from the simulator or connected device and then repeat steps 6-8. If this does not work then proceed to "How to send a test crash"

## How to send a test crash
```
CordovaFirebasePlugin.reportNonFatalCrash("Test Error Name", "Test Error Message", "Test Error URL", "Test Error Stacktrace")
```
Build the app, run it with Xcode on a device/simulator, press stop in Xcode, reopen the app, run the above crash report code, exit the app, remove it from the background, and then reopen it to send the test crash.

### PhoneGap
You will have to manually place your configuration file in the `platforms/ios/My Project/Resources` folder of your project and hard code the app id and api key in `plugin.xml`.

## How to use the plugin
The plugin currently does not have typings.
- Place this code before the @Component in typescript:
```
declare var CordovaFirebasePlugin: any;
```

- Place this code before any other code in a javascript/jquery mobile app
```
var CordovaFirebasePlugin;
```

- Example use in an application:
```
CordovaFirebasePlugin.setAnalyticsScreenName("Login");
```

```
CordovaFirebasePlugin.setCrashlyticsUserID("123");
```

```
CordovaFirebasePlugin.setAnalyticsUserID("123");
```

```
CordovaFirebasePlugin.reportEvent("Login_Success", {timestamp:new Date()} );
```

```
CordovaFirebasePlugin.setAnalyticsUserProperty("Role", "Admin");
```

- Example Crashlytics reporting of Javascript/Typescript errors:
```
CordovaFirebasePlugin.reportNonFatalCrash("errorName", "errorMessage", "errorUrl", "stackTrace");
```

### Note
- Check out the CordovaFirebasePlugin.js file for more commands

### Note
- Native errors will be caught and reported automatically to Crashlytics
- Javascript/Non-fatal errors will be categorized and grouped, in Crashlytics, by the length of the error