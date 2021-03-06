//
//  UIViewController+BSToast.m
//  void_toast
//
//  Created by ucredit-XiaoYang on 16/4/25.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "UIViewController+BSToast.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

// Keys for values associated with self
static const void * BSStatusToastActiveToastViewKey   = @"com.XiaoYang.BSStatusToastActiveToastViewKey";
static const void * BSStatusToastQueueKey             = @"com.XiaoYang.BSStatusToastQueueKey";
static const void * BSStatusToastDurationKey          = @"com.XiaoYang.BSStatusToastDurationKey";
static const void * BSControllerViewToWindowY         = @"com.XiaoYang.BSControllerViewToWindowY";


// 动画展示时间
static const NSTimeInterval BSStatusToastFadeDuration     = 0.2;


@interface BSToastLabel ()
// toast所属控制器
@property (nonatomic, strong) UIViewController *targetController;

@end

@implementation BSToastLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    if ([UIViewController pr_isIphoneX] && self.frame.origin.y == 0) {
        insets = UIEdgeInsetsMake(24, 10, 0, 10);
    }
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end



@implementation UIViewController (BSToast)

- (void)bs_showToast:(NSString *)message {
    [self bs_showToast:message style:nil];
}

- (void)bs_showToast:(NSString *)message style:(BSStatusToastStyle *)style {
    if (!message || ![message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) return;
    BSStatusToastStyle *sty = style ?: [[BSStatusToastStyle alloc] initWithStatusToastDefaultStyle];
    BSToastLabel *toast = [self toastViewForMessage:message style:sty];
    [self showToast:toast duration:toast.statusToastStyle.duration];
}


- (void)showToast:(BSToastLabel *)toast duration:(NSTimeInterval)duration {
    if (toast == nil) return;
    
    [self pr_jadgeToastTargetController:toast];
    
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


#pragma mark - private method
- (void)pr_jadgeToastTargetController:(BSToastLabel *)toast {

    if (!self.bs_isViewDidAppear) {
        [self performSelector:@selector(pr_jadgeToastTargetController:)
                   withObject:toast
                   afterDelay:0.15];
        return;
    }

    if (self.presentedViewController) {
        if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)self.presentedViewController;
            toast.targetController = nav.topViewController;
        } else {
            toast.targetController = self.presentedViewController;
        }
    } else {
        toast.targetController = self;
    }
}

// 首次展示toast之前判断当前view是否已经完全加载
- (void)bs_jadgeShowToast {
    BSToastLabel *toast = objc_getAssociatedObject(self, &BSStatusToastActiveToastViewKey);
    if (toast.targetController.bs_isViewDidAppear) {
        [self pr_showToast];
    } else {
        [self performSelector:@selector(bs_jadgeShowToast) withObject:nil afterDelay:0.15];
    }
}


- (void)pr_showToast {
    BSToastLabel *toast = objc_getAssociatedObject(self, &BSStatusToastActiveToastViewKey);
    NSTimeInterval duration = [objc_getAssociatedObject(toast, &BSStatusToastDurationKey) doubleValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self bs_showToastWithDuration:duration];
    });
}


- (void)bs_showToastWithDuration:(NSTimeInterval)duration {
    [self bs_showToastWithDuration:duration toast:nil];
}

- (void)bs_showToastWithDuration:(NSTimeInterval)duration toast:(BSToastLabel *)currentToast {
    BSToastLabel *toast = objc_getAssociatedObject(self, &BSStatusToastActiveToastViewKey);
    if (!toast) return;
    [self bs_showToast:toast
              duration:duration
          currentToast:currentToast
            targetView:toast.targetController.view];
}

// 展示toast动画
- (void)bs_showToast:(BSToastLabel *)toast
            duration:(NSTimeInterval)duration
        currentToast:(BSToastLabel *)currentToast
          targetView:(UIView *)view {
    
    [view.superview addSubview:toast];
    [view.superview bringSubviewToFront:toast];
    
    CGRect frame = [view convertRect:view.bounds toView:UIApplication.sharedApplication.delegate.window];
    CGFloat Y = CGRectGetMinY(frame);
    
    // 记录Y值
    objc_setAssociatedObject(self, &BSControllerViewToWindowY, @(Y).stringValue, OBJC_ASSOCIATION_COPY);
    
    if (currentToast && currentToast.statusToastStyle.animationStyle == BSStatusToastAnimationFollow) {
        Y -= currentToast.statusToastStyle.toastHeight;
    }
    
    toast.frame = CGRectMake(0, Y, [[UIScreen mainScreen] bounds].size.width, 0);
    
    // 页面没有navigationBar的情况，展示toast时隐藏状态栏，防止遮挡
    if (![UIViewController pr_isIphoneX] && Y == 0) {
        UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
        statusBar.hidden = !toast.isHidden;
    }
    
    // 确定toast高度
    CGFloat toastHeight = toast.statusToastStyle.toastHeight;
    if ([UIViewController pr_isIphoneX] && Y == 0) {
        toastHeight += 30;
    }
    
    [UIView animateWithDuration:BSStatusToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         toast.frame = CGRectMake(0, Y, [[UIScreen mainScreen] bounds].size.width, toastHeight);
                        
                         if (toast.statusToastStyle.animationStyle == BSStatusToastAnimationFollow) {
                            
                             view.frame = CGRectMake(CGRectGetMinX(view.frame),
                                                     Y + toastHeight,
                                                     CGRectGetWidth(view.frame),
                                                     CGRectGetHeight(view.frame));
                         
                         }
                         
                     } completion:^(BOOL finished) {
                         
                         NSTimer *timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(bs_toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                         
                     }];
}

// 每一个toast展示时间结束后回调，需判断当前缓存队列中是否还有需要展示的toast
- (void)bs_toastTimerDidFinish:(NSTimer *)timer {
    BSToastLabel *toast = (BSToastLabel *)timer.userInfo;
    // 这里判断队列，展示动画效果【view不复原，接连弹出下一个toast，直到队列为空，view复原】
    if (self.bs_toastQueue.count > 0) {
        [self pr_showNextToast:toast];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast removeFromSuperview];
        });
    } else {
        [self bs_hideToast:(BSToastLabel *)timer.userInfo];
    }
}

// 隐藏toast
- (void)bs_hideToast:(BSToastLabel *)toast {
    
    CGFloat Y = CGRectGetMinY(toast.frame);
    
    // 确定toast高度
    CGFloat toastHeight = toast.statusToastStyle.toastHeight;
    if ([UIViewController pr_isIphoneX] && Y == 0) {
        toastHeight += 30;
    }
    
    [UIView animateWithDuration:BSStatusToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         toast.frame = CGRectMake(0, Y, [[UIScreen mainScreen] bounds].size.width, 0);
                         
                         if (toast.statusToastStyle.animationStyle == BSStatusToastAnimationFollow) {
                             
                             UIView *displayView = toast.targetController.view;
                             displayView.frame = CGRectMake(CGRectGetMinX(displayView.frame),
                                                            Y,
                                                            CGRectGetWidth(displayView.frame),
                                                            CGRectGetHeight(displayView.frame));
                             
                         }
                         
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                         
                         // 这里判断队列，展示动画效果【view会随toast复原，然后接连弹出下一个toast，直到队列为空】
                         if ([self.bs_toastQueue count] > 0) {
                             [self pr_showNextToast:nil];
                         } else {
                             // clear the active toast
                             objc_setAssociatedObject(self, &BSStatusToastActiveToastViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             if (Y == 0) {
                                 UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
                                 statusBar.hidden = NO;
                             }
                         }
                     }];
}

// 展示下一个已经在队列中的toast
- (void)pr_showNextToast:(BSToastLabel *)currentToast {
    // dequeue 出队列
    BSToastLabel *nextToast = [[self bs_toastQueue] firstObject];
    [[self bs_toastQueue] removeObjectAtIndex:0];
    
    // 更新当前绑定的Toast
    objc_setAssociatedObject(self, &BSStatusToastActiveToastViewKey, nextToast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // present the next toast 弹出toast
    NSTimeInterval duration = [objc_getAssociatedObject(nextToast, &BSStatusToastDurationKey) doubleValue];
    [self bs_showToastWithDuration:duration toast:currentToast];
}

+ (BOOL)pr_isIphoneX {
    if (@available(iOS 11.0, *)) {
        return !UIEdgeInsetsEqualToEdgeInsets(UIApplication.sharedApplication.keyWindow.safeAreaInsets, UIEdgeInsetsZero);
    }
    return NO;
}


#pragma mark - Queue

// 队列，用来存放多条未展示的toast
- (NSMutableArray *)bs_toastQueue {
    NSMutableArray *bs_toastQueue = objc_getAssociatedObject(self, &BSStatusToastQueueKey);
    if (bs_toastQueue == nil) {
        bs_toastQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &BSStatusToastQueueKey, bs_toastQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return bs_toastQueue;
}

// toast view
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
    label.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 0);
    
    return label;
}

@end



@implementation UIViewController (BSVisible)

+ (void)load {
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class myClass = [self class];
        SEL originSelector = @selector(viewDidAppear:);
        SEL newSelector = @selector(bs_viewDidAppear:);
        Method originM =class_getInstanceMethod(myClass, originSelector);
        Method newM=class_getInstanceMethod(myClass, newSelector);
        method_exchangeImplementations(originM, newM); // 方法调换
        
        SEL originDisappear = @selector(viewWillDisappear:);
        SEL newDisappear = @selector(bs_viewWillDisappear:);
        Method originDisappearMethod = class_getInstanceMethod(myClass, originDisappear);
        Method newDisappearMethod = class_getInstanceMethod(myClass, newDisappear);
        method_exchangeImplementations(originDisappearMethod, newDisappearMethod);
        
    });
}

- (void)bs_viewDidAppear:(BOOL)animated {
    self.bs_isViewDidAppear = YES;
    [self bs_viewDidAppear:animated];
}

- (BOOL)bs_isViewDidAppear {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)bs_setViewDidAppear:(BOOL)bs_isViewDidAppear {
    objc_setAssociatedObject(self, @selector(bs_isViewDidAppear), @(bs_isViewDidAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self performSelectorOnMainThread:@selector(pr_setViewRecovery) withObject:nil waitUntilDone:YES];
}

- (void)bs_viewWillDisappear:(BOOL)animated {
    [self performSelectorOnMainThread:@selector(pr_setActiveToastHidden) withObject:nil waitUntilDone:YES];
    [self bs_viewWillDisappear:animated];
}

- (void)pr_setActiveToastHidden {
    BSToastLabel *toast = objc_getAssociatedObject(self, &BSStatusToastActiveToastViewKey);
    if (toast) {
        NSMutableArray *bs_toastQueue = objc_getAssociatedObject(self, &BSStatusToastQueueKey);
        [bs_toastQueue removeAllObjects];
        toast.hidden = YES;
        
        CGRect rect;
        rect.origin = CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y - toast.statusToastStyle.toastHeight);
        rect.size = self.view.frame.size;
        self.view.frame = rect;
    }
}

- (void)pr_setViewRecovery {
    // 记录Y值
    NSString *Y = objc_getAssociatedObject(self, &BSControllerViewToWindowY);
    if (!Y.length) { return; }
    if (self.view.frame.origin.y > Y.floatValue) {
        self.view.frame = CGRectMake(CGRectGetMinX(self.view.frame),
                                     Y.floatValue,
                                     CGRectGetWidth(self.view.frame),
                                     CGRectGetHeight(self.view.frame));
    }
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
        self.animationStyle = BSStatusToastAnimationFollow;
        
    }
    return self;
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end


