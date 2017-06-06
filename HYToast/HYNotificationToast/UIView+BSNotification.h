//
//  UIView+BSNotification.h
//  HYToastDemo
//
//  Created by ucredit-XiaoYang on 2017/6/5.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSNotificationView.h"


@interface UIView (BSNotification)

- (void)makeNotification:(BSNotificationView *)notification
                duration:(NSTimeInterval)duration;

- (void)makeNotification:(BSNotificationView *)notification
                duration:(NSTimeInterval)duration
                complate:(BSNotificationCompletionBlock)block;

@end

