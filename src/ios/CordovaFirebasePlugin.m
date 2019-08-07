#import "CordovaFirebasePlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import "Firebase.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FirebaseAnalytics;
@import FirebaseRemoteConfig;
@import FirebasePerformance;
@import FirebaseAuth;

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation CordovaFirebasePlugin

@synthesize notificationCallbackId;
@synthesize tokenRefreshCallbackId;
@synthesize notificationStack;
@synthesize traces;

static NSInteger const kNotificationStackSize = 10;
static CordovaFirebasePlugin *cordovaFirebasePlugin;

+ (CordovaFirebasePlugin *) cordovaFirebasePlugin {
    return cordovaFirebasePlugin;
}

- (void)pluginInitialize {
    NSLog(@"Initializing the Cordova Firebase plugin");
    cordovaFirebasePlugin = self;
}

- (void)getFirebaseInstanceId:(CDVInvokedUrlCommand *)command {
    __block CDVPluginResult *pluginResult;
    FIRInstanceIDHandler handler = ^(NSString *_Nullable instID, NSError *_Nullable error) {
        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:instID];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    [[FIRInstanceID instanceID] getIDWithHandler:handler];
}

- (void)getFirebaseToken:(CDVInvokedUrlCommand *)command {
        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result.token];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
    
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result.token];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
    
   
}

- (void)checkPermissions:(CDVInvokedUrlCommand *)command {
    BOOL enabled = NO;
    UIApplication *application = [UIApplication sharedApplication];

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        enabled = application.currentUserNotificationSettings.types != UIUserNotificationTypeNone;
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        enabled = application.enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
#pragma GCC diagnostic pop
    }

    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:1];
    [message setObject:[NSNumber numberWithBool:enabled] forKey:@"isEnabled"];
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

- (void)grantPermissions:(CDVInvokedUrlCommand *)command {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        if ([[UIApplication sharedApplication]respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType notificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma GCC diagnostic pop
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter]
        requestAuthorizationWithOptions:authOptions
                      completionHandler:^(BOOL granted, NSError * _Nullable error) {

            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[FIRMessaging messaging] setDelegate:self];
                    [[UIApplication sharedApplication] registerForRemoteNotifications];

                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: granted ? CDVCommandStatus_OK : CDVCommandStatus_ERROR];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                });
            } else {
                [[FIRMessaging messaging] setDelegate:self];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    ];
#else
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
#endif

    return;
}

- (void)verifyPhone:(CDVInvokedUrlCommand *)command {
    NSString* number = [command.arguments objectAtIndex:0];
    [[FIRPhoneAuthProvider provider]
    verifyPhoneNumber:number
           UIDelegate:nil
           completion:^(NSString *_Nullable verificationID, NSError *_Nullable error) {
    NSDictionary *message;
    if (error) {
        message = @{
            @"code": [NSNumber numberWithInteger:error.code],
            @"description": error.description == nil ? [NSNull null] : error.description
        };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:message];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:verificationID];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  }];
}

- (void)setApplicationBadgeNumber:(CDVInvokedUrlCommand *)command {
    int number = [[command.arguments objectAtIndex:0] intValue];

    [self.commandDelegate runInBackground:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getApplicationBadgeNumber:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        long badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:badge];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)subscribeToFirebaseMsg:(CDVInvokedUrlCommand *)command {
    NSString* topic = [NSString stringWithFormat:@"/topics/%@", [command.arguments objectAtIndex:0]];

    [[FIRMessaging messaging] subscribeToTopic: topic];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)unsubscribeFromFirebaseMsg:(CDVInvokedUrlCommand *)command {
    NSString* topic = [NSString stringWithFormat:@"/topics/%@", [command.arguments objectAtIndex:0]];

    [[FIRMessaging messaging] unsubscribeFromTopic: topic];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)deregisterInstanceID:(CDVInvokedUrlCommand *)command {
    [[FIRInstanceID instanceID] deleteIDWithHandler:^void(NSError *_Nullable error) {
        if (error) {
            NSLog(@"Unable to deregister instance");
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)onApplicationNotificationOpen:(CDVInvokedUrlCommand *)command {
    self.notificationCallbackId = command.callbackId;

    if (self.notificationStack != nil && [self.notificationStack count]) {
        for (NSDictionary *userInfo in self.notificationStack) {
            [self sendNotification:userInfo];
        }
        [self.notificationStack removeAllObjects];
    }
}

- (void)onFirebaseTokenRefresh:(CDVInvokedUrlCommand *)command {
    self.tokenRefreshCallbackId = command.callbackId;
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
             if (result.token != nil) {
                [self sendToken:result.token];
              }
        }
    }];
}

- (void)sendNotification:(NSDictionary *)userInfo {
    if (self.notificationCallbackId != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.notificationCallbackId];
    } else {
        if (!self.notificationStack) {
            self.notificationStack = [[NSMutableArray alloc] init];
        }
        [self.notificationStack addObject:userInfo];

        if ([self.notificationStack count] >= kNotificationStackSize) {
            [self.notificationStack removeLastObject];
        }
    }
}

- (void)sendToken:(NSString *)token {
    if (self.tokenRefreshCallbackId != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.tokenRefreshCallbackId];
    }
}

- (void)reportEvent:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* name = [command.arguments objectAtIndex:0];
        NSDictionary *parameters;
        @try {
            NSString *description = NSLocalizedString([command argumentAtIndex:1 withDefault:@"No Event provided"], nil);
            parameters = @{ NSLocalizedDescriptionKey: description };
        }
        @catch (NSException *execption) {
            parameters = [command argumentAtIndex:1];
        }

        [FIRAnalytics logEventWithName:name parameters:parameters];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)addCrashLog:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* errorMessage = [command.arguments objectAtIndex:0];
        CLSNSLog(@"%@", errorMessage);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)reportNonFatalCrash:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
       //NSLog(@"%@", eStackTrace);
        NSString* errorName = [command.arguments objectAtIndex:0];
        NSString* errorMessage = [command.arguments objectAtIndex:1];
        NSString* errorUrl = [command.arguments objectAtIndex:2];
        NSString* errorStackTrace = [command.arguments objectAtIndex:3];
        NSString *domain = @"Non-fatal Crash";
        NSString *eName = NSLocalizedString(errorName, @"");
        NSString *eMessage = NSLocalizedString(errorMessage, @"");
        NSString *eUrl = NSLocalizedString(errorUrl, @"");
        NSString *eStackTrace = NSLocalizedString(errorStackTrace, @"");
        NSString *Name = @"Name";
        NSString *Message = @"Message";
        NSString *Url = @"Url";
        NSString *StackTrace = @"StackTrace";
        NSDictionary *userInfo = @{ Name : eName, Message: eMessage, Url: eUrl, StackTrace: eStackTrace };
        NSError *error = [NSError errorWithDomain:domain code:-101 userInfo:userInfo];
        [CrashlyticsKit recordError:error];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setCrashlyticsUserID:(CDVInvokedUrlCommand *)command {
    NSString* userId = [command.arguments objectAtIndex:0];
    [CrashlyticsKit setUserIdentifier:userId];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAnalyticsScreenName:(CDVInvokedUrlCommand *)command {
    NSString* name = [command.arguments objectAtIndex:0];
    [FIRAnalytics setScreenName:name screenClass:NULL];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAnalyticsUserID:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* id = [command.arguments objectAtIndex:0];
        [FIRAnalytics setUserID:id];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setAnalyticsUserProperty:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* name = [command.arguments objectAtIndex:0];
        NSString* value = [command.arguments objectAtIndex:1];
        [FIRAnalytics setUserPropertyString:value forName:name];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getRemoteConfig:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
          FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
          if ([command.arguments count] > 0) {
              int expirationDuration = [[command.arguments objectAtIndex:0] intValue];
              [remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  CDVPluginResult *pluginResult;
                  if (status == FIRRemoteConfigFetchStatusSuccess) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                  } else {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                  }
                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              }];
          } else {
              [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  CDVPluginResult *pluginResult;
                  if (status == FIRRemoteConfigFetchStatusSuccess) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                  } else {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                  }
                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              }];
          }
    }];
}

- (void)implementRemoteConfig:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
        FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
         BOOL activated = [remoteConfig activateFetched];
         CDVPluginResult *pluginResult;
         if (activated) {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
         } else {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
         }
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}

- (void)getRemoteConfigValue:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* key = [command.arguments objectAtIndex:0];
        FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
        NSString* value = remoteConfig[key].stringValue;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)startPerformanceTrace:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* traceName = [command.arguments objectAtIndex:0];
        FIRTrace *trace = [self.traces objectForKey:traceName];
        if ( self.traces == nil) {
            self.traces = [NSMutableDictionary new];
        }
        if (trace == nil) {
            trace = [FIRPerformance startTraceWithName:traceName];
            [self.traces setObject:trace forKey:traceName ];
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }];
}

//- (void)traceIncrementCounter:(CDVInvokedUrlCommand *)command {
   // [self.commandDelegate runInBackground:^{
   //     NSString* traceName = [command.arguments objectAtIndex:0];
   //     NSString* counterNamed = [command.arguments objectAtIndex:1];
   //     CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
   //     FIRTrace *trace = (FIRTrace*)[self.traces objectForKey:traceName];
   //     if (trace != nil) {
    //        [trace incrementCounterNamed:counterNamed];
    //        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    //    } else {
     //       pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Performance Trace not found"];
     //   }
    //    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  //  }];
//}

- (void)stopPerformanceTrace:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* traceName = [command.arguments objectAtIndex:0];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        FIRTrace *trace = [self.traces objectForKey:traceName];
        if (trace != nil) {
            [trace stop];
            [self.traces removeObjectForKey:traceName];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Performance Trace not found"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)enableAnalyticsReporting:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
        BOOL enabled = [[command argumentAtIndex:0] boolValue];
         [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)enablePerformanceReporting:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         BOOL enabled = [[command argumentAtIndex:0] boolValue];
         [[FIRPerformance sharedInstance] setDataCollectionEnabled:enabled];
         CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}

- (void)clearNotifications:(CDVInvokedUrlCommand *)command {
	[self.commandDelegate runInBackground:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
@end
