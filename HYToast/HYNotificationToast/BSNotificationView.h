//
//  BSNotificationView.h
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/5.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BSNotificationView;


typedef void(^BSNotificationCompletionBlock)(BSNotificationView *view, BOOL finish);


typedef void(^BSNotificationActionBlock)(BSNotificationView *view);


@interface BSNotificationView : UIView

// 动画的持续时间， 默认0.3
@property (nonatomic, assign) NSTimeInterval animationDuration;

// 是否需要在展示期间，隐藏statusBar，默认YES
@property (nonatomic, assign) BOOL hideStautsBarWhenShowAnimation;

// 是否需要在展示期间，开启手机短振动，默认YES
// 并不是所有手机型号都具备，大概是iPhone6sP之后的型号具备的特征
@property (nonatomic, assign) BOOL impactFeedbackWhenShowAnimation;

// 布局， 默认UIEdgeInsetsMake(10, 10, 0, 10)
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

// 点击事件的回调
@property (nonatomic, copy) BSNotificationActionBlock actionBlock;

// 完成事件的回调
@property (nonatomic, copy) BSNotificationCompletionBlock showCompletionBlock;
@property (nonatomic, copy) BSNotificationCompletionBlock hideCompletionBlock;


- (void)show;

- (void)hide;

- (void)showWithBlock:(BSNotificationCompletionBlock)block;

- (void)hideWithBlock:(BSNotificationCompletionBlock)block;

@end
