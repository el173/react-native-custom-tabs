#import "CustomTabs.h"
#import <React/RCTUtils.h>
#import <React/RCTLog.h>
#import <AuthenticationServices/ASWebAuthenticationSession.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
ASWebAuthenticationSession *_authenticationVC;
#pragma clang diagnostic pop

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#import <AuthenticationServices/AuthenticationServices.h>
@interface CustomTabs() <ASWebAuthenticationPresentationContextProviding>
@end
#endif

@implementation CustomTabs

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(
                  openUrl:(NSURL *)requestURL
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock)  reject
                  )
{
    if (!requestURL) {
        RCTLogError(@"[CustomTabs] No URL found");
        reject("[CustomTabs] No URL found");
    }
    
    if(![requestURL hasPrefix:@"http"] || ![requestURL hasPrefix:@"https"]) {
        RCTLogError(@"[CustomTabs] Allow only http or https URL : ", requestURL);
        reject(@"[CustomTabs] Allow only http or https URL :" stringByAppendingString:requestURL);
    }
    
    if (@available(iOS 12.0, *)) {
        ASWebAuthenticationSession* authenticationVC =
        [[ASWebAuthenticationSession alloc] initWithURL:requestURL
                                      callbackURLScheme: @""
                                      completionHandler:^(NSURL * _Nullable callbackURL,
                                                          NSError * _Nullable error) {
            _authenticationVC = nil;
            
            if (callbackURL) {
                [RCTSharedApplication() openURL:callbackURL];
                resolve(callbackURL.absoluteString);
            }
        }];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            authenticationVC.presentationContextProvider = self;
        }
#endif
        
        _authenticationVC = authenticationVC;
        
        [authenticationVC start];
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#pragma mark - ASWebAuthenticationPresentationContextProviding

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session  API_AVAILABLE(ios(13.0)){
    return UIApplication.sharedApplication.keyWindow;
}
#endif

@end

