//
//  UIViewController+BSToast.h
//  void_toast
//
//  Created by ucredit-XiaoYang on 16/4/25.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSStatusToastStyle;



@interface BSToastLabel : UILabel

@property (nonatomic, strong) BSStatusToastStyle *statusToastStyle;

@end




@interface UIViewController (BSToast)

+ (BOOL)pr_isIphoneX;

- (void)bs_showToast:(NSString *)message;

- (void)bs_showToast:(NSString *)message
               style:(BSStatusToastStyle *)style;

@end



@interface UIViewController (BSVisible)

/**
 *  判断当前view是否加载完毕
 */
@property (nonatomic, assign, setter=bs_setViewDidAppear:) BOOL bs_isViewDidAppear;

@end



typedef NS_ENUM(NSUInteger, BSStatusToastAnimationStyle) {
    BSStatusToastAnimationFollow,
    BSStatusToastAnimationCover,
};

@interface BSStatusToastStyle : NSObject

/**
 *  Toast持续时间
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 *  Toast动画类型
 *  follow - 当前视图跟随下滑
 *  cover - 覆盖当前视图下滑
 */
@property (nonatomic, assign) BSStatusToastAnimationStyle animationStyle;

/**
 *   The background color. Default is `[UIColor orangeColor]`.
 */
@property (nonatomic, strong) UIColor *backgroundColor;


/**
 *   The message color. Default is `[UIColor whiteColor]`.
 */
@property (strong, nonatomic) UIColor *messageColor;


/**
 *   The message font. Default is `[UIFont systemFontOfSize:14]`.
 */
@property (strong, nonatomic) UIFont *messageFont;


/**
 *   The Toast View Height. Default is `20`.
 */
@property (assign, nonatomic) CGFloat toastHeight;


- (instancetype)initWithStatusToastDefaultStyle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end


