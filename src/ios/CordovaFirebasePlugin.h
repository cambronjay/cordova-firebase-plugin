#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
+ (FirebasePlugin *) firebasePlugin;
- (void)verifyPhone:(CDVInvokedUrlCommand*)command;
- (void)getFirebaseInstanceId:(CDVInvokedUrlCommand*)command;
- (void)getFirebaseToken:(CDVInvokedUrlCommand*)command;
- (void)checkPermissions:(CDVInvokedUrlCommand*)command;
- (void)grantPermissions:(CDVInvokedUrlCommand*)command;
- (void)setApplicationBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)getApplicationBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)subscribeToFirebaseMsg:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromFirebaseMsg:(CDVInvokedUrlCommand*)command;
- (void)deregisterInstanceID:(CDVInvokedUrlCommand*)command;
- (void)onApplicationNotificationOpen:(CDVInvokedUrlCommand*)command;
- (void)onFirebaseTokenRefresh:(CDVInvokedUrlCommand*)command;
- (void)sendNotification:(NSDictionary*)userInfo;
- (void)sendToken:(NSString*)token;
- (void)reportEvent:(CDVInvokedUrlCommand*)command;
- (void)addCrashLog:(CDVInvokedUrlCommand*)command;
- (void)reportNonFatalCrash:(CDVInvokedUrlCommand*)command;
- (void)setCrashlyticsUserID:(CDVInvokedUrlCommand*)command;
- (void)setAnalyticsScreenName:(CDVInvokedUrlCommand*)command;
- (void)setAnalyticsUserID:(CDVInvokedUrlCommand*)command;
- (void)setAnalyticsUserProperty:(CDVInvokedUrlCommand*)command;
- (void)getRemoteConfig:(CDVInvokedUrlCommand*)command;
- (void)implementRemoteConfig:(CDVInvokedUrlCommand*)command;
- (void)getRemoteConfigValue:(CDVInvokedUrlCommand*)command;
- (void)startPerformanceTrace:(CDVInvokedUrlCommand*)command;
- (void)traceIncrementCounter:(CDVInvokedUrlCommand*)command;
- (void)stopPerformanceTrace:(CDVInvokedUrlCommand*)command;
- (void)enableAnalyticsReporting:(CDVInvokedUrlCommand*)command;
- (void)enablePerformanceReporting:(CDVInvokedUrlCommand*)command;
- (void)clearNotifications:(CDVInvokedUrlCommand *)command;
@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSString *tokenRefreshCallbackId;
@property (nonatomic, retain) NSMutableArray *notificationStack;
@property (nonatomic, readwrite) NSMutableDictionary* traces;

@end