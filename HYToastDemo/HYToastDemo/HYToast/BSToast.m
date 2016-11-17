//
//  BSToast.m
//  StarterKit
//
//  Created by XiaoYang on 15/10/8.
//  Copyright © 2015年 XiaoYang. All rights reserved.
//

#import "BSToast.h"
#import "UIViewController+CurrentVC.h"
#import "UINavigationController+Toast.h"
#import "ISMessages.h"

#if __has_include(<Toast/UIView+Toast.h>)
#import <Toast/UIView+Toast.h>
#else
#import "UIView+Toast.h"
#endif



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



@interface BSToast ()

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
        self.notificationToastStyle = nil;
    }
    return self;
}

#pragma mark - appearance

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BSToast alloc] init];
    });
    return sharedInstance;
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
        [ISMessages showISMessageToastWithTitle:nil message:message alertType:ISAlertTypeInfo style:nil];
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
            [ISMessages showISMessageToastWithTitle:nil
                                            message:message
                                          alertType:ISAlertTypeInfo
                                              style:nil];
        }
    }
    else {
        [ISMessages showISMessageToastWithTitle:nil
                                        message:message
                                      alertType:ISAlertTypeInfo
                                          style:nil];
    }
}



#pragma mark - Notification style

+ (void)showInfoToast:(NSString *)message {
    [BSToast showToastWithTitle:nil
                        message:message
                      alertType:BSAlertToastTypeInfo];
}

+ (void)showWarningToast:(NSString *)message {
    [BSToast showToastWithTitle:nil
                        message:message
                      alertType:BSAlertToastTypeWarning];
}

+ (void)showErrorToast:(NSString *)message {
    [BSToast showToastWithTitle:nil
                        message:message
                      alertType:BSAlertToastTypeError];
}

+ (void)showSuccessToast:(NSString *)message {
    [BSToast showToastWithTitle:nil
                        message:message
                      alertType:BSAlertToastTypeSuccess];
}

+ (void)showToastWithTitle:(NSString *)title
                   message:(NSString *)message
                 alertType:(BSAlertToastType)type {
    BSToast *toast = [BSToast shareManager];

    [ISMessages showISMessageToastWithTitle:title
                                    message:message
                                  alertType:(ISAlertType)type
                                      style:toast.notificationToastStyle];
}

@end
