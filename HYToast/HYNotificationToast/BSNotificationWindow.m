//
//  BSNotificationWindow.m
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/16.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import "BSNotificationWindow.h"
#import "BSNotificationView.h"


@implementation BSNotificationWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.userInteractionEnabled = NO;
        self.windowLevel = UIWindowLevelStatusBar + 1;
    }
    return self;
}

+ (BSNotificationWindow *)sharedWindow {
    static BSNotificationWindow *window;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        window = [[BSNotificationWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = [UIViewController new];
    });
    
    return window;
}

- (UIView *)attachView {
    return self.rootViewController.view;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.hidden && self.alpha > 0.01 && self.isUserInteractionEnabled) {
        //判断点击位置是否在自己区域内部
        if ([self pointInside: point withEvent:event]) {
            UIView *attachedView;
            
            for (UIView *view in self.subviews.firstObject.subviews) {
                if ([view isKindOfClass:[BSNotificationView class]]) {
                    attachedView = [view hitTest:point withEvent:event];
                    if (attachedView)
                        break;
                }
            }
            
            return attachedView;
        }
    }
    return nil;
}

@end
