//
//  BSStatusToastManager.h
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/7.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BSStatusToastStyle;


#define showStatusToast(args) [BSStatusToastManager showStatusToast:args];


@interface BSStatusToastManager : NSObject

@property (nonatomic, strong) BSStatusToastStyle *style;


+ (instancetype)share;


#pragma mark - public method
- (void)showStatusToast:(NSString *)message;
+ (void)showStatusToast:(NSString *)message;


@end

