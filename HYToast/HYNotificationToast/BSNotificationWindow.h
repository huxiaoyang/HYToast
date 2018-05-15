//
//  BSNotificationWindow.h
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/16.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSNotificationWindow : UIWindow

@property (nonatomic, strong ,readonly) UIView* attachView;

+ (BSNotificationWindow *)sharedWindow;

@end
