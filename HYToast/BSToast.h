//
//  BSToast.h
//  StarterKit
//
//  Created by XiaoYang on 15/10/8.
//  Copyright © 2015年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CSToastStyle;
@class BSStatusToastStyle;
@class ISMessagesStyle;



typedef NS_ENUM(NSInteger, BSToastPosition) {
    BSToastPositionTop,
    BSToastPositionCenter,
    BSToastPositionBottom
};

typedef NS_ENUM(NSInteger, BSAlertToastType) {
    // Green alert view with check mark image.
    BSAlertToastTypeSuccess = 0,
    // Red alert view with error image
    BSAlertToastTypeError = 1,
    // Orange alert view with warning image
    BSAlertToastTypeWarning = 2,
    // Light green alert with info image.
    BSAlertToastTypeInfo = 3,
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
                 alertType:(BSAlertToastType)type;
@end
