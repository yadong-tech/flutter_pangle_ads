#import "FlutterPangleAdsPlugin.h"
#import "NativeViewFactory.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@implementation FlutterPangleAdsPlugin
// 广告位id
NSString *const kPosId=@"posId";
// AdBannerView
NSString *const kAdBannerViewId=@"flutter_pangle_ads_banner";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* methodChannel = [FlutterMethodChannel
                                           methodChannelWithName:@"flutter_pangle_ads"
                                           binaryMessenger:[registrar messenger]];
    FlutterEventChannel* eventChannel=[FlutterEventChannel eventChannelWithName:@"flutter_pangle_ads_event" binaryMessenger:[registrar messenger]];
    FlutterPangleAdsPlugin* instance = [[FlutterPangleAdsPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:methodChannel];
    [eventChannel setStreamHandler:instance];
    // 注册平台View 工厂
    NativeViewFactory *factory=[[NativeViewFactory alloc] initWithMessenger:registrar.messenger withPlugin:instance];
    // 注册 Banner View
    [registrar registerViewFactory:factory withId:kAdBannerViewId];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *methodStr=call.method;
    if ([@"getPlatformVersion" isEqualToString:methodStr]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else if ([@"requestIDFA" isEqualToString:methodStr]) {
        [self requestIDFA:call result:result];
    }else if ([@"initAd" isEqualToString:methodStr]) {
        [self initAd:call result:result];
    }else if([@"showSplashAd" isEqualToString:methodStr]) {
        [self showSplashAd:call result:result];
    }else if ([@"showInterstitialAd" isEqualToString:methodStr]){
        [self showInterstitialAd:call result:result];
    }else if ([@"showRewardVideoAd" isEqualToString:methodStr]){
        [self showRewardVideoAd:call result:result];
    }else if ([@"showFullScreenVideoAd" isEqualToString:methodStr]){
        [self showFullScreenVideoAd:call result:result];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

// 请求 IDFA
- (void) requestIDFA:(FlutterMethodCall*) call result:(FlutterResult) result{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            BOOL requestResult=status == ATTrackingManagerAuthorizationStatusAuthorized;
            NSLog(@"requestIDFA:%@",requestResult?@"YES":@"NO");
            result(@(requestResult));
        }];
    } else {
        result(@(YES));
    }
}

// 初始化广告
- (void) initAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    NSString* appId=call.arguments[@"appId"];
    BUAdSDKConfiguration *config = [BUAdSDKConfiguration configuration];
    config.appID=appId;
    [BUAdSDKManager startWithSyncCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"initAd:%@",success?@"YES":@"NO");
        result(@(success));
    }];
}

// 显示开屏广告
- (void) showSplashAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    self.posId=call.arguments[kPosId];
    self.sad=[[SplashPage alloc] init];
    [self.sad showAd:self.posId methodCall:call eventSink:self.eventSink];
    result(@(YES));
}

// 显示插屏广告
- (void) showInterstitialAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    self.posId=call.arguments[kPosId];
    self.iad=[[InterstitialPage alloc] init];
    [self.iad showAd:self.posId methodCall:call eventSink:self.eventSink];
    result(@(YES));
}

// 显示激励视频广告
- (void) showRewardVideoAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    self.posId=call.arguments[kPosId];
    self.rvad=[[RewardVideoPage alloc] init];
    [self.rvad showAd:self.posId methodCall:call eventSink:self.eventSink];
    result(@(YES));
}

// 显示全屏视频广告
- (void) showFullScreenVideoAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    self.posId=call.arguments[kPosId];
    self.fsad=[[FullScreenVideoPage alloc] init];
    [self.fsad showAd:self.posId methodCall:call eventSink:self.eventSink];
    result(@(YES));
}


#pragma mark - FlutterStreamHandler
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink=nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.eventSink=events;
    return nil;
}

// 添加事件
-(void) addEvent:(NSObject *) event{
    if(self.eventSink!=nil){
        self.eventSink(event);
    }
}

@end
