//
//  BSToast.h
//  StarterKit
//
//  Created by XiaoYang on 15/10/8.
//  Copyright © 2015年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Toast/UIView+Toast.h>
#import "UINavigationController+Toast.h"
#import <ISMessages/ISMessages.h>


typedef NS_ENUM(NSInteger, BSToastPosition) {
    BSToastPositionTop,
    BSToastPositionCenter,
    BSToastPositionBottom
};


@interface BSToast : NSObject

#pragma mark - Properties

@property (nonatomic, assign) BSToastPosition toastPosition;
@property (nonatomic, assign) NSUInteger toastDuration;
@property (nonatomic, strong) CSToastStyle *toastStyle;
@property (nonatomic, strong) BSStatusToastStyle *statusToastStyle;
@property (nonatomic, strong) ISMessagesStyle *notificationToastStyle;


+ (instancetype)shareManager;


#pragma mark - Android Toast style
- (void)showToast:(NSString *)message;
+ (void)showToast:(NSString *)message;


#pragma mark - StatusBar style
- (void)showStatusToast:(NSString *)message;
+ (void)showStatusToast:(NSString *)message;


#pragma mark - Notification Style
+ (void)showSuccessToast:(NSString *)message;
+ (void)showErrorToast:(NSString *)message;
+ (void)showWarningToast:(NSString *)message;
+ (void)showInfoToast:(NSString *)message;
+ (void)showToastWithTitle:(NSString *)title
                   message:(NSString *)message
                 alertType:(ISAlertType)type;
@end
