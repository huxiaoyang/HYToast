//
//  BSToast.m
//  StarterKit
//
//  Created by XiaoYang on 15/10/8.
//  Copyright © 2015年 XiaoYang. All rights reserved.
//

#import "BSToast.h"
#import "UIViewController+CurrentVC.h"


NSString *NSStringFromLLToastPosition(BSToastPosition position) {
    switch (position) {
        case BSToastPositionTop:
            return @"top";
        case BSToastPositionCenter:
            return @"center";
        case BSToastPositionBottom:
            return @"bottom";
    }
    return nil;
};



@interface BSToast () <MZAppearance>

@end

@implementation BSToast


#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // default toast
        self.toastDuration = 1.5;
        self.toastPosition = BSToastPositionBottom;
        self.toastStyle = nil;
        
        self.statusToastStyle = nil;
        
        // default notifications style toast
        self.toastType = CRToastTypeNavigationBar;
        self.toastPresentationType = CRToastPresentationTypeCover;
        self.toastTextAlignment = NSTextAlignmentCenter;
        self.toastAnimationInType = CRToastAnimationTypeGravity;
        self.toastAnimationOutType = CRToastAnimationTypeGravity;
        self.toastAnimationInDirection = CRToastAnimationDirectionTop;
        self.toastAnimationOutDirection = CRToastAnimationDirectionTop;
        self.toastFont = [UIFont systemFontOfSize:16];
        self.toastTextColor = [UIColor whiteColor];
        self.toastBackgroundColor = [UIColor orangeColor];
        
        // apply the appearance
        [[[self class] appearance] applyInvocationTo:self];
    }
    return self;
}

#pragma mark - appearance

+ (id)appearance {
    return [MZAppearance appearanceForClass:[self class]];
}


#pragma mark - Toast

+ (void)showToast:(NSString *)message {
    BSToast *toast = [BSToast shareManager];
    
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *toastView = [mainWindow toastViewForMessage:message title:nil image:nil style:toast.toastStyle];
    [mainWindow showToast:toastView duration:toast.toastDuration position:NSStringFromLLToastPosition(toast.toastPosition) completion:nil];
}

- (void)showToast:(NSString *)message {
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *toastView = [mainWindow toastViewForMessage:message title:nil image:nil style:nil];
    [mainWindow showToast:toastView duration:self.toastDuration position:NSStringFromLLToastPosition(self.toastPosition) completion:nil];
}


#pragma mark - StatusBar style
- (void)showStatusToast:(NSString *)message {
    UIViewController *currentViewController = [UIViewController bs_getCurrentVC];
    if ([currentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)currentViewController;
        [navi showToast:message style:self.statusToastStyle];
    } else {
        if (![CRToastManager isShowingNotification]) {
            [CRToastManager showNotificationWithOptions:[BSToast buildOptions:self withMessage:message] completionBlock:nil];
        }
    }
}

+ (void)showStatusToast:(NSString *)message {
    BSToast *toast = [BSToast shareManager];
    
    UIViewController *currentViewController = [UIViewController bs_getCurrentVC];
    if ([currentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)currentViewController;
        [navi showToast:message style:toast.statusToastStyle];
    }
    else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)currentViewController;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = tab.selectedViewController;
            [navi showToast:message style:toast.statusToastStyle];
        } else {
            if (![CRToastManager isShowingNotification]) {
                [CRToastManager showNotificationWithOptions:[BSToast buildOptions:toast withMessage:message] completionBlock:nil];
            }
        }
    }
    else {
        if (![CRToastManager isShowingNotification]) {
            [CRToastManager showNotificationWithOptions:[BSToast buildOptions:toast withMessage:message] completionBlock:nil];
        }
    }
}



#pragma mark - Notification style

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BSToast alloc] init];
    });
    return sharedInstance;
}

+ (void)showToastNotificationStyle:(NSString *)message {
    BSToast *toast = [BSToast shareManager];
    if (![CRToastManager isShowingNotification]) {
        [CRToastManager showNotificationWithOptions:[BSToast buildOptions:toast withMessage:message] completionBlock:nil];
    }
    
}

- (void)showToastNotificationStyle:(NSString *)message {
    [CRToastManager showNotificationWithOptions:[BSToast buildOptions:self withMessage:message] completionBlock:nil];
}

+ (NSMutableDictionary *)buildOptions:(BSToast *)toast withMessage:(NSString *)message {
    NSMutableDictionary *options = [NSMutableDictionary new];
    [options setObject:@(toast.toastType) forKey:kCRToastNotificationTypeKey];
    [options setObject:@(toast.toastPresentationType) forKey:kCRToastNotificationPresentationTypeKey];
    [options setObject:@(toast.toastTextAlignment) forKey:kCRToastTextAlignmentKey];
    [options setObject:@(toast.toastDuration) forKey:kCRToastTimeIntervalKey];
    [options setObject:toast.toastBackgroundColor forKey:kCRToastBackgroundColorKey];
    [options setObject:@(toast.toastAnimationInType) forKey:kCRToastAnimationInTypeKey];
    [options setObject:@(toast.toastAnimationOutType) forKey:kCRToastAnimationOutTypeKey];
    [options setObject:@(toast.toastAnimationInDirection) forKey:kCRToastAnimationInDirectionKey];
    [options setObject:@(toast.toastAnimationOutDirection) forKey:kCRToastAnimationOutDirectionKey];
    [options setObject:toast.toastFont forKey:kCRToastFontKey];
    [options setObject:toast.toastTextColor forKey:kCRToastTextColorKey];
    
    // append message
    [options setObject:message forKey:kCRToastTextKey];
    return options;
}


@end
