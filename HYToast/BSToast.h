//
//  BSToast.h
//  StarterKit
//
//  Created by XiaoYang on 15/10/8.
//  Copyright © 2015年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZAppearance.h"
#import <UIKit/UIKit.h>
#import "CRToast.h"
#import "UIView+Toast.h"
#import "UINavigationController+Toast.h"


typedef NS_ENUM(NSInteger, BSToastPosition) {
    BSToastPositionTop,
    BSToastPositionCenter,
    BSToastPositionBottom
};


@interface BSToast : NSObject

#pragma mark - Properties


@property (nonatomic, assign) BSToastPosition toastPosition MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger toastDuration MZ_APPEARANCE_SELECTOR;
@property (nonatomic, strong) CSToastStyle *toastStyle MZ_APPEARANCE_SELECTOR;

@property (nonatomic, strong) BSStatusToastStyle *statusToastStyle MZ_APPEARANCE_SELECTOR;

@property (nonatomic, assign) CRToastType toastType MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CRToastPresentationType toastPresentationType MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTextAlignment toastTextAlignment MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CRToastAnimationType toastAnimationInType MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CRToastAnimationType toastAnimationOutType MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CRToastAnimationDirection toastAnimationInDirection MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CRToastAnimationDirection toastAnimationOutDirection MZ_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *toastFont MZ_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *toastTextColor MZ_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *toastBackgroundColor MZ_APPEARANCE_SELECTOR;



#pragma mark - MZAppearance
+ (id)appearance;


#pragma mark - Android Toast style
- (void)showToast:(NSString *)message;
+ (void)showToast:(NSString *)message;


#pragma mark - StatusBar style
- (void)showStatusToast:(NSString *)message;
+ (void)showStatusToast:(NSString *)message;


#pragma mark - Notification Style
- (void)showToastNotificationStyle:(NSString *)message;
+ (void)showToastNotificationStyle:(NSString *)message;

@end
