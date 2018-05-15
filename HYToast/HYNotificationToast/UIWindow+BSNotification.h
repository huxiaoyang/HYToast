//
//  UIViewController+BSNotification.h
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/5.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSNotificationView.h"


#define showNotificationToast(NotificationToastView) \
[[[[UIApplication sharedApplication] delegate] window] bs_makeNotification:NotificationToastView duration:1.5];


@interface UIWindow (BSNotification)

- (void)bs_makeNotification:(BSNotificationView *)notification
                   duration:(NSTimeInterval)duration;

- (void)bs_makeNotification:(BSNotificationView *)notification
                   duration:(NSTimeInterval)duration
                   complate:(BSNotificationCompletionBlock)block;

@end

