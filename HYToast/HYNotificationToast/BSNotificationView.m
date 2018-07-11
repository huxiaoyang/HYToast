//
//  BSNotificationView.m
//  void_toast
//
//  Created by ucredit-XiaoYang on 2017/6/5.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import "BSNotificationView.h"
#import "BSNotificationWindow.h"
#import <AudioToolbox/AudioToolbox.h>


#define NotificationWeakify(o)        __weak   typeof(self) mmwo = o;
#define NotificationStrongify(o)      __strong typeof(self) o = mmwo;

typedef void(^BSNotificationBlock)(BSNotificationView *);


@interface BSNotificationView ()

@property (nonatomic, copy) BSNotificationBlock showAnimation;
@property (nonatomic, copy) BSNotificationBlock hideAnimation;

@property (nonatomic, copy) BSNotificationCompletionBlock tmpShowCompletionBlock;
@property (nonatomic, copy) BSNotificationCompletionBlock tmpHideCompletionBlock;

@property (nonatomic, strong) UIImpactFeedbackGenerator *generator;

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
    self.impactFeedbackWhenShowAnimation = YES;
    CGFloat left = 10.f;
    CGFloat top = ([[UIScreen mainScreen] bounds].size.height == 812.f) ? 40.f : 10.f;
    self.edgeInsets = UIEdgeInsetsMake(top, left, 0, left);
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
     
        [[BSNotificationWindow sharedWindow] setHidden:NO];
        
        BSNotificationBlock showAnimation = self.showAnimation;
        
        NSAssert(showAnimation, @"show animation must be there");
        
        showAnimation(self);

    });
}

- (void)hideWithBlock:(BSNotificationCompletionBlock)block {
    if (block) {
        self.tmpHideCompletionBlock = block;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        BSNotificationBlock hideAnimation = self.hideAnimation;
        
        NSAssert(hideAnimation, @"show animation must be there");
        
        hideAnimation(self);
        
    });
    
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
        
        if (self.impactFeedbackWhenShowAnimation) {
            AudioServicesPlaySystemSound(1519);
        }
        
        [[[BSNotificationWindow sharedWindow] attachView] addSubview:self];
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
                             
                             [self removeFromSuperview];
                             
                             if (self.hideCompletionBlock) {
                                 self.hideCompletionBlock(self, YES);
                             }
                             
                             if (self.tmpHideCompletionBlock) {
                                 self.tmpHideCompletionBlock(self, YES);
                             }
                             
                             if (self.hideStautsBarWhenShowAnimation) {
                                 UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
                                 statusBar.hidden = NO;
                             }
                             
                             [[BSNotificationWindow sharedWindow] setHidden:YES];
                             
                         }];
        
    };
    
    return block;
}

#pragma mark - setter

- (void)setHideStautsBarWhenShowAnimation:(BOOL)hideStautsBarWhenShowAnimation {
    if ([[UIScreen mainScreen] bounds].size.height == 812.f) {
        _hideStautsBarWhenShowAnimation = NO;
        return;
    }
    _hideStautsBarWhenShowAnimation = hideStautsBarWhenShowAnimation;
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
