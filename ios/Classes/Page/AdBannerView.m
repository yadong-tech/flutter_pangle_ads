//
//  AdBannerView.m
//  flutter_pangle_ads
//
//  Created by zero on 2021/8/31.
//

#import "AdBannerView.h"
// Banner 广告 View
@interface AdBannerView()<FlutterPlatformView,BUNativeExpressBannerViewDelegate>
@property (strong,nonatomic) BUNativeExpressBannerView *bannerView;
@end
// Banner 广告 View
@implementation AdBannerView
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                       plugin:(FlutterPangleAdsPlugin*) plugin{
    if (self = [super init]) {
        self.args=args;
        NSString* posId = args[kPosId];
        [self showAd:posId methodCall:nil eventSink:plugin.eventSink];
    }
    return self;
}

- (UIView*)view {
    return self.bannerView;
}
// 加载广告
- (void)loadAd:(FlutterMethodCall *)call{
    // 刷新间隔
    int interval=[self.args[@"interval"] intValue];
    int width = [self.args[@"width"] intValue];
    int height = [self.args[@"height"] intValue];
    // 大于 0 说明需要设置刷新间隔
    if(interval>0){
        self.bannerView=[[BUNativeExpressBannerView alloc] initWithSlotID:self.posId rootViewController:self.mainWin.rootViewController adSize:CGSizeMake(width, height) interval:interval];
    }else{
        self.bannerView=[[BUNativeExpressBannerView alloc] initWithSlotID:self.posId rootViewController:self.mainWin.rootViewController adSize:CGSizeMake(width, height)];
    }
    self.bannerView.frame=CGRectMake(0, 0, width, height);
    self.bannerView.delegate=self;
    [self.bannerView loadAdData];
}

#pragma mark BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__FUNCTION__);
    // 发送广告事件
    [self sendEventAction:onAdLoaded];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    // 发送广告错误事件
    [self sendErrorEvent:error.code withErrMsg:error.localizedDescription];
    self.bannerView=nil;
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__FUNCTION__);
    // 发送广告事件
    [self sendEventAction:onAdExposure];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    // 发送广告错误事件
    [self sendErrorEvent:error.code withErrMsg:error.localizedDescription];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__FUNCTION__);
    // 发送广告事件
    [self sendEventAction:onAdExposure];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__FUNCTION__);
    // 发送广告事件
    [self sendEventAction:onAdClicked];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    NSLog(@"%s",__FUNCTION__);
}

- (void)nativeExpressBannerAdViewDidRemoved:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__FUNCTION__);
    [bannerAdView removeFromSuperview];
    // 发送广告事件
    [self sendEventAction:onAdClosed];
}

@end
