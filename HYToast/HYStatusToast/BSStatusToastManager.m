//
//  BSStatusToastManager.m
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/7.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import "BSStatusToastManager.h"
#import "UIViewController+BSToast.h"


@implementation BSStatusToastManager

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BSStatusToastManager alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.style = nil;
    }
    return self;
}


#pragma mark - StatusBar style

- (void)showStatusToast:(NSString *)message {
    UIViewController *controller = [BSStatusToastManager pr_findWindowController];
    [controller bs_showToast:message style:self.style];
}

+ (void)showStatusToast:(NSString *)message {
    BSStatusToastManager *toast = [BSStatusToastManager share];
    UIViewController *controller = [BSStatusToastManager pr_findWindowController];
    [controller bs_showToast:message style:toast.style];
}


#pragma mark - find controller

+ (UIViewController *)pr_findWindowController {
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return [BSStatusToastManager pr_findBestViewController:viewController];
}

+ (UIViewController *)pr_findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [BSStatusToastManager pr_findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0)
            return [BSStatusToastManager pr_findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0)
            return [BSStatusToastManager pr_findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0)
            return [BSStatusToastManager pr_findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

@end



