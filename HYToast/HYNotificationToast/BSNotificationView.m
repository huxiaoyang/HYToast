//
//  BSNotificationView.m
//  HYToastDemo
//
//  Created by ucredit-XiaoYang on 2017/6/5.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import "BSNotificationView.h"

#define NotificationWeakify(o)        __weak   typeof(self) mmwo = o;
#define NotificationStrongify(o)      __strong typeof(self) o = mmwo;

typedef void(^BSNotificationBlock)(BSNotificationView *);


@interface BSNotificationView ()

@property (nonatomic, copy) BSNotificationBlock showAnimation;
@property (nonatomic, copy) BSNotificationBlock hideAnimation;

@property (nonatomic, copy) BSNotificationCompletionBlock tmpShowCompletionBlock;
@property (nonatomic, copy) BSNotificationCompletionBlock tmpHideCompletionBlock;

@end


@implementation BSNotificationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.animationDuration = 0.3f;
    self.hideStautsBarWhenShowAnimation = YES;
    self.edgeInsets = UIEdgeInsetsMake(10, 10, 0, 10);
    self.showAnimation = [self showToastAnimation];
    self.hideAnimation = [self hideToastAnimation];
}


#pragma mark - pubilc method
- (void)show {
    [self showWithBlock:nil];
}

- (void)hide {
    [self hideWithBlock:nil];
}

- (void)showWithBlock:(BSNotificationCompletionBlock)block {
    if (block) {
        self.tmpShowCompletionBlock = block;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BSNotificationBlock showAnimation = self.showAnimation;
        
        NSAssert(showAnimation, @"show animation must be there");
        
        showAnimation(self);

    });
}

- (void)hideWithBlock:(BSNotificationCompletionBlock)block {
    if (block) {
        self.tmpHideCompletionBlock = block;
    }
    
    BSNotificationBlock hideAnimation = self.hideAnimation;
    
    NSAssert(hideAnimation, @"show animation must be there");
    
    hideAnimation(self);
}


#pragma mark - 设置动画
- (BSNotificationBlock)showToastAnimation {
    NotificationWeakify(self);
    BSNotificationBlock block = ^(BSNotificationView *make) {
        NotificationStrongify(self);
        
        if (self.hideStautsBarWhenShowAnimation) {
            UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
            statusBar.hidden = YES;
        }
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
        self.frame = [self setupHideNotificationViewFrame];
        
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.frame = [self setupShowNotificationViewFrame];
                             
                         } completion:^(BOOL finished) {
                             
                             if (self.showCompletionBlock) {
                                 self.showCompletionBlock(self, finished);
                             }
                             
                             if (self.tmpShowCompletionBlock) {
                                 self.tmpShowCompletionBlock(self, finished);
                             }
                             
                         }];
        
    };
    
    return block;
}

- (BSNotificationBlock)hideToastAnimation {
    NotificationWeakify(self);
    BSNotificationBlock block = ^(BSNotificationView *make) {
        NotificationStrongify(self);
        
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.frame = [self setupHideNotificationViewFrame];
                             
                         } completion:^(BOOL finished) {
                             
                             if (finished) {
                                 [self removeFromSuperview];
                             }
                             
                             if (self.hideCompletionBlock) {
                                 self.hideCompletionBlock(self, finished);
                             }
                             
                             if (self.tmpHideCompletionBlock) {
                                 self.tmpHideCompletionBlock(self, finished);
                             }
                             
                             if (self.hideStautsBarWhenShowAnimation) {
                                 UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
                                 statusBar.hidden = NO;
                             }
                             
                         }];
        
    };
    
    return block;
}


#pragma mark - 设置frame变化
- (CGRect)setupHideNotificationViewFrame {
    CGRect rect;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat x = self.edgeInsets.left;
    CGFloat y = -(self.frame.size.height + self.edgeInsets.top);
    rect.origin = CGPointMake(x, y);
    rect.size = CGSizeMake(screenW - (self.edgeInsets.left + self.edgeInsets.right), self.frame.size.height);
    return rect;
}

- (CGRect)setupShowNotificationViewFrame {
    CGRect rect;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat x = self.edgeInsets.left;
    CGFloat y = self.edgeInsets.top;
    rect.origin = CGPointMake(x, y);
    rect.size = CGSizeMake(screenW - (self.edgeInsets.left + self.edgeInsets.right), self.frame.size.height);
    return rect;
}

@end
