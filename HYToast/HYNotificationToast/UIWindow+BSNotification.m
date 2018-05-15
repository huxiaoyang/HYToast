//
//  UIViewController+BSNotification.m
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/5.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import "UIWindow+BSNotification.h"
#import "BSNotificationView.h"
#import <objc/runtime.h>


static const void * BSNotificationActiveViewKey   = @"com.XiaoYang.BSNotificationActiveViewKey";
static const void * BSNotificationQueueKey        = @"com.XiaoYang.BSNotificationQueueKey";
static const void * BSNotificationTimerKey        = @"com.XiaoYang.BSNotificationTimerKey";

static const void * BSNotificationDurtionKey      = @"com.XiaoYang.BSNotificationDurtionKey";


@implementation UIWindow (BSNotification)

- (void)bs_makeNotification:(BSNotificationView *)notification
                   duration:(NSTimeInterval)duration {
    [self bs_makeNotification:notification duration:duration complate:nil];
}


- (void)bs_makeNotification:(BSNotificationView *)notification
                   duration:(NSTimeInterval)duration
                   complate:(BSNotificationCompletionBlock)block {
    
    objc_setAssociatedObject(notification, &BSNotificationDurtionKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (objc_getAssociatedObject(self, &BSNotificationActiveViewKey) != nil ||
        self.pr_notificationQueue.count > 0) {
        
        [self.pr_notificationQueue addObject:notification];
        
    } else {
        
        objc_setAssociatedObject(self, &BSNotificationActiveViewKey, notification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self pr_showNotification:notification complation:block];
        
    }
    
}

- (void)pr_showNotification:(BSNotificationView *)notification
                 complation:(BSNotificationCompletionBlock)block {
    [notification showWithBlock:^(BSNotificationView *view, BOOL finish) {
        
        NSTimeInterval duration = [objc_getAssociatedObject(notification, &BSNotificationDurtionKey) doubleValue];
        
        if (finish) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:duration
                                                     target:self
                                                   selector:@selector(pr_notificationTimerDidFinish:)
                                                   userInfo:notification
                                                    repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
            objc_setAssociatedObject(notification, &BSNotificationTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pr_notificationTapGestureRecognizer:)];
            [notification addGestureRecognizer:tap];
            
            UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pr_notificationSwipeGestureRecognizer:)];
            swipe.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
            [notification addGestureRecognizer:swipe];
            
        }
        
        if (block) block(view, finish);
    }];

}

// timer执行事件
- (void)pr_notificationTimerDidFinish:(NSTimer *)timer {
    BSNotificationView *notification = timer.userInfo;
    
    NSTimeInterval duration = [objc_getAssociatedObject(notification, &BSNotificationDurtionKey) doubleValue];
    
    if (self.pr_notificationQueue.count > 0) {
        
        [self pr_showNextNotification];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + notification.animationDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [notification removeFromSuperview];
        });
    
    } else {
        
        [notification hideWithBlock:^(BSNotificationView *view, BOOL finish) {
            
            if (finish) {
                objc_setAssociatedObject(self, &BSNotificationActiveViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            
        }];
        
    }
}

// 点击事件
- (void)pr_notificationTapGestureRecognizer:(UIGestureRecognizer *)gesture {
    BSNotificationView *notification = (BSNotificationView *)gesture.view;
    
    if (notification.actionBlock) {
        notification.actionBlock(notification);
    }
    
    [self pr_notificationSwipeGestureRecognizer:gesture];
}

// 滑动事件
- (void)pr_notificationSwipeGestureRecognizer:(UIGestureRecognizer *)gesture {
    BSNotificationView *notification = (BSNotificationView *)gesture.view;

    NSTimer *timer = objc_getAssociatedObject(notification, &BSNotificationTimerKey);
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval endTimer = [timer.fireDate timeIntervalSince1970];
    [timer invalidate];
    
    [notification hideWithBlock:^(BSNotificationView *view, BOOL finish) {
        
        if (finish) {
            objc_setAssociatedObject(self, &BSNotificationActiveViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
    }];
    
    if (current > endTimer)
        return;
    
    if (self.pr_notificationQueue.count > 0) {
        [self pr_showNextNotification];
    }
}

// 展示队列中下一条数据
- (void)pr_showNextNotification {
    BSNotificationView *notification = [[self pr_notificationQueue] firstObject];
    [[self pr_notificationQueue] removeObjectAtIndex:0];
    
    NSTimeInterval duration = [objc_getAssociatedObject(notification, &BSNotificationDurtionKey) doubleValue];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self pr_showNotification:notification complation:nil];
    });
}

#pragma mark - 队列
// 队列，用来存放多条未展示的toast
- (NSMutableArray *)pr_notificationQueue {
    NSMutableArray *pr_notificationQueue = objc_getAssociatedObject(self, &BSNotificationQueueKey);
    if (pr_notificationQueue == nil) {
        pr_notificationQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &BSNotificationQueueKey, pr_notificationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return pr_notificationQueue;
}


@end
