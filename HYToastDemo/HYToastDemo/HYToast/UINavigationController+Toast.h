//
//  UINavigationController+Toast.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/25.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSStatusToastStyle;



@interface BSToastLabel : UILabel

@property (nonatomic, strong) BSStatusToastStyle *statusToastStyle;

@end




@interface UINavigationController (Toast)

- (void)showToast:(NSString *)message style:(BSStatusToastStyle *)style;


@end



@interface UIViewController (Toast)

/**
 *  判断当前view是否初始化完成
 */
- (BOOL)bs_isViewVisible;

@end



@interface BSStatusToastStyle : NSObject

/**
 *  Toast持续时间
 */
@property (nonatomic, assign) NSTimeInterval duration;


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


