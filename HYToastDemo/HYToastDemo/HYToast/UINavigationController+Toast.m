//
//  UINavigationController+Toast.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/25.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "UINavigationController+Toast.h"
#import "UIView+BSKit.h"
#import <objc/runtime.h>


static const NSString * BSStatusToastDurationKey          = @"com.XiaoYang.BSStatusToastDurationKey";


// Keys for values associated with self
static const NSString * BSStatusToastActiveToastViewKey   = @"com.XiaoYang.BSStatusToastActiveToastViewKey";
static const NSString * BSStatusToastActivityViewKey      = @"com.XiaoYang.BSStatusToastActivityViewKey";
static const NSString * BSStatusToastQueueKey             = @"com.XiaoYang.BSStatusToastQueueKey";

// 动画展示时间
static const NSTimeInterval BSStatusToastFadeDuration     = 0.2;

// NavigationBar height
static const CGFloat BSNavigationBarHeight                = 64.0f;



@implementation BSToastLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end



@implementation UINavigationController (Toast)

- (void)showToast:(NSString *)message style:(BSStatusToastStyle *)style {
    BSToastLabel *toast = [self toastViewForMessage:message style:style];
    [self showToast:toast duration:toast.statusToastStyle.duration];
}


- (void)showToast:(BSToastLabel *)toast duration:(NSTimeInterval)duration {
    if (toast == nil) return;
    
    // 记录toast时间
    objc_setAssociatedObject(toast, &BSStatusToastDurationKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (objc_getAssociatedObject(self, &BSStatusToastActiveToastViewKey) != nil) {
        // 加入队列
        [self.bs_toastQueue addObject:toast];
    } else {
        // 记录Toast本身
        objc_setAssociatedObject(self, &BSStatusToastActiveToastViewKey, toast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        // 递归方法
        [self bs_jadgeShowToast];
    }
}

- (void)bs_jadgeShowToast {
    if (self.presentedViewController) {
        [self bs_showPresentedRecursionToast];
    } else {
        [self bs_showRecursionToast];
    }
}

- (void)bs_showRecursionToast {
    if (self.topViewController.bs_isViewVisible) {
        BSToastLabel *toast = objc_getAssociatedObject(self, &BSStatusToastActiveToastViewKey);
        NSTimeInterval duration = [objc_getAssociatedObject(toast, &BSStatusToastDurationKey) doubleValue];
        [self bs_showToast:toast duration:duration];
    } else {
        [self performSelector:@selector(bs_jadgeShowToast) withObject:self afterDelay:0.3];
    }
}

- (void)bs_showPresentedRecursionToast {
    UINavigationController *Nav = (UINavigationController *)self.presentedViewController;
    if ([Nav isKindOfClass:[UINavigationController class]] && Nav.topViewController.bs_isViewVisible) {
        BSToastLabel *toast = objc_getAssociatedObject(self, &BSStatusToastActiveToastViewKey);
        NSTimeInterval duration = [objc_getAssociatedObject(toast, &BSStatusToastDurationKey) doubleValue];
        [self bs_showToast:toast duration:duration];
    } else {
        [self performSelector:@selector(bs_jadgeShowToast) withObject:self afterDelay:0.3];
    }
}

- (void)bs_showToast:(BSToastLabel *)toast duration:(NSTimeInterval)duration {
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:toast];
    
    [UIView animateWithDuration:BSStatusToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         
                         toast.frame = CGRectMake(0, BSNavigationBarHeight, [[UIScreen mainScreen] bounds].size.width, toast.statusToastStyle.toastHeight);
                         
                         if (self.presentedViewController) {
                             UINavigationController *Nav = (UINavigationController *)self.presentedViewController;
                             if (Nav.topViewController.view.topValue == 0 || Nav.topViewController.view.topValue == BSNavigationBarHeight) {
                                 [Nav.topViewController.view setTransform:CGAffineTransformTranslate(Nav.topViewController.view.transform, 0, toast.statusToastStyle.toastHeight)];
                                 objc_setAssociatedObject(self, &BSStatusToastActivityViewKey, Nav.topViewController.view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             }
                         }
                         else {
                             if (self.topViewController.view.topValue == 0 || self.topViewController.view.topValue == BSNavigationBarHeight) {
                                 [self.topViewController.view setTransform:CGAffineTransformTranslate(self.topViewController.view.transform, 0, toast.statusToastStyle.toastHeight)];
                                 objc_setAssociatedObject(self, &BSStatusToastActivityViewKey, self.topViewController.view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             }
                         }
                         
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(bs_toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                     }];
}


- (void)bs_toastTimerDidFinish:(NSTimer *)timer {
    [self bs_hideToast:(BSToastLabel *)timer.userInfo];
}


- (void)bs_hideToast:(BSToastLabel *)toast {
    [UIView animateWithDuration:BSStatusToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         toast.frame = CGRectMake(0, BSNavigationBarHeight, [[UIScreen mainScreen] bounds].size.width, 0);
                         UIView *displayView = objc_getAssociatedObject(self, &BSStatusToastActivityViewKey);
                         if (displayView.topValue == toast.statusToastStyle.toastHeight || displayView.topValue == toast.statusToastStyle.toastHeight+BSNavigationBarHeight) {
                             [displayView setTransform:CGAffineTransformTranslate(displayView.transform, 0, -toast.statusToastStyle.toastHeight)];
                         }
                         
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                         
                         // clear the active toast
                         objc_setAssociatedObject(self, &BSStatusToastActiveToastViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         
                         if ([self.bs_toastQueue count] > 0) {
                             // dequeue
                             BSToastLabel *nextToast = [[self bs_toastQueue] firstObject];
                             [[self bs_toastQueue] removeObjectAtIndex:0];
                             
                             // present the next toast
                             NSTimeInterval duration = [objc_getAssociatedObject(nextToast, &BSStatusToastDurationKey) doubleValue];
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [self bs_showToast:nextToast duration:duration];
                             });
                         }
                     }];
}

#pragma mark - Queue

- (NSMutableArray *)bs_toastQueue {
    NSMutableArray *bs_toastQueue = objc_getAssociatedObject(self, &BSStatusToastQueueKey);
    if (bs_toastQueue == nil) {
        bs_toastQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &BSStatusToastQueueKey, bs_toastQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return bs_toastQueue;
}


- (BSToastLabel *)toastViewForMessage:(NSString *)message style:(BSStatusToastStyle *)style {
    
    if (message == nil) return nil;
    
    if (style == nil) {
        style = [[BSStatusToastStyle alloc] initWithStatusToastDefaultStyle];
    }
    
    BSToastLabel *label = [[BSToastLabel alloc] init];
    label.statusToastStyle = style;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = message;
    label.textColor = style.messageColor;
    label.font = style.messageFont;
    label.backgroundColor = style.backgroundColor;
    label.frame = CGRectMake(0, BSNavigationBarHeight, [[UIScreen mainScreen] bounds].size.width, 0);
    
    return label;
}

@end



@implementation UIViewController (Toast)

- (BOOL)bs_isViewVisible {
    return (self.isViewLoaded && self.view.window);
}

@end


@implementation BSStatusToastStyle

- (instancetype)initWithStatusToastDefaultStyle {
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor orangeColor];
        self.messageColor = [UIColor whiteColor];
        self.messageFont = [UIFont systemFontOfSize:13];
        self.toastHeight = 25.0f;
        self.duration = 1.5;
        
    }
    return self;
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end


