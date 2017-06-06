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


static const void * BSStatusToastDurationKey          = @"com.XiaoYang.BSStatusToastDurationKey";


// Keys for values associated with self
static const void * BSStatusToastActiveToastViewKey   = @"com.XiaoYang.BSStatusToastActiveToastViewKey";
static const void * BSStatusToastQueueKey             = @"com.XiaoYang.BSStatusToastQueueKey";

// 动画展示时间
static const NSTimeInterval BSStatusToastFadeDuration     = 0.2;


@interface BSToastLabel ()
// toast所属控制器
@property (nonatomic, strong) UIViewController *targetController;
// toast的初始frame的Y值
@property (nonatomic, assign) CGFloat originY;

@end

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
    if (self.presentedViewController) {
        if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)self.presentedViewController;
            toast.targetController = nav.topViewController;
            if (nav.navigationBar.frame.origin.y > 0) {
                CGFloat barHeight = nav.navigationBar.frame.origin.y + nav.navigationBar.frame.size.height;
                toast.originY = barHeight;
            } else {
                toast.originY = 0;
            }
        } else {
            toast.targetController = self.presentedViewController;
            toast.originY = 0;
        }
    } else {
        toast.targetController = self.topViewController;
        // 判断当前页面是否显式的存在navigationBar，如果navigationBar隐藏了，y<0
        if (self.topViewController.navigationController.navigationBar.frame.origin.y > 0) {
            CGFloat barHeight = self.topViewController.navigationController.navigationBar.frame.origin.y + self.topViewController.navigationController.navigationBar.frame.size.height;
            toast.originY = barHeight;
        } else {
            toast.originY = 0;
        }
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
        [self bs_showToast:toast
                  duration:duration];
    });
}


- (void)bs_showToast:(BSToastLabel *)toast duration:(NSTimeInterval)duration {
    [self bs_showToast:toast
              duration:duration
               originY:toast.originY
            targetView:toast.targetController.view];
}

// 展示toast动画
- (void)bs_showToast:(BSToastLabel *)toast duration:(NSTimeInterval)duration originY:(CGFloat)Y targetView:(UIView *)view {
    [view.superview addSubview:toast];
    [view.superview bringSubviewToFront:toast];
    // 页面没有navigationBar的情况，展示toast时隐藏状态栏，防止遮挡
    if (Y == 0) {
        UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
        statusBar.hidden = YES;
    }
    toast.frame = CGRectMake(0, Y, [[UIScreen mainScreen] bounds].size.width, 0);
    
    [UIView animateWithDuration:BSStatusToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         toast.frame = CGRectMake(0, Y, [[UIScreen mainScreen] bounds].size.width, toast.statusToastStyle.toastHeight);
                         if (view.topValue != toast.statusToastStyle.toastHeight && view.topValue != toast.statusToastStyle.toastHeight+Y) {
                             [view setTransform:CGAffineTransformTranslate(view.transform, 0, toast.statusToastStyle.toastHeight)];
                         }
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(bs_toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                     }];
}

// 每一个toast展示时间结束后回调，需判断当前缓存队列中是否还有需要展示的toast
// 这里判断队列，展示动画效果【view不复原，接连弹出下一个toast，直到队列为空，view复原】
- (void)bs_toastTimerDidFinish:(NSTimer *)timer {
    BSToastLabel *toast = (BSToastLabel *)timer.userInfo;
    if (self.bs_toastQueue.count > 0) {
        [self pr_showNextToast];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast removeFromSuperview];
        });
    } else {
        [self bs_hideToast:(BSToastLabel *)timer.userInfo];
    }
}

// 隐藏toast
- (void)bs_hideToast:(BSToastLabel *)toast {
    [UIView animateWithDuration:BSStatusToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         toast.frame = CGRectMake(0, toast.originY, [[UIScreen mainScreen] bounds].size.width, 0);
                         UIView *displayView = toast.targetController.view;
                         if (displayView.topValue == toast.statusToastStyle.toastHeight ||
                             displayView.topValue == toast.statusToastStyle.toastHeight + toast.originY) {
                             [displayView setTransform:CGAffineTransformTranslate(displayView.transform, 0, -toast.statusToastStyle.toastHeight)];
                         }
                         
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];

                         // 这里判断队列，展示动画效果【view会随toast复原，然后接连弹出下一个toast，直到队列为空】
                         if ([self.bs_toastQueue count] > 0) {
                             [self pr_showNextToast];
                         } else {
                             // clear the active toast
                             objc_setAssociatedObject(self, &BSStatusToastActiveToastViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             if (toast.originY == 0) {
                                 UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
                                 statusBar.hidden = NO;
                             }
                         }
                     }];
}

// 展示下一个已经在队列中的toast
- (void)pr_showNextToast {
    // dequeue 出队列
    BSToastLabel *nextToast = [[self bs_toastQueue] firstObject];
    [[self bs_toastQueue] removeObjectAtIndex:0];
    
    // present the next toast 弹出toast
    NSTimeInterval duration = [objc_getAssociatedObject(nextToast, &BSStatusToastDurationKey) doubleValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self bs_showToast:nextToast duration:duration];
    });
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



@implementation UIViewController (Toast)

+ (void)load {
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class myClass = [self class];
        SEL originSelector = @selector(viewDidAppear:);
        SEL newSelector = @selector(bs_viewDidAppear:);
        Method originM =class_getInstanceMethod(myClass, originSelector);
        Method newM=class_getInstanceMethod(myClass, newSelector);
        method_exchangeImplementations(originM, newM); // 方法调换
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


