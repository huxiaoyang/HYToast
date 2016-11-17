//
//  UIView+BSKit.m
//  StarterKit
//
//  Created by XiaoYang on 15/10/13.
//  Copyright © 2015年 XiaoYang. All rights reserved.
//

#import "UIView+BSKit.h"

@implementation UIView (BSKit)

- (CGFloat)leftValue {
    return self.frame.origin.x;
}

- (void)setLeftValue:(CGFloat)leftValue {
    CGRect frame = self.frame;
    frame.origin.x = leftValue;
    self.frame = frame;
}

- (CGFloat)rightValue {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRightValue:(CGFloat)rightValue {
    CGRect frame = self.frame;
    frame.origin.x = rightValue - frame.size.width;
    self.frame = frame;
}

- (CGFloat)topValue {
    return self.frame.origin.y;
}

- (void)setTopValue:(CGFloat)topValue {
    CGRect frame = self.frame;
    frame.origin.y = topValue;
    self.frame = frame;
}

- (CGFloat)bottomValue {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottomValue:(CGFloat)bottomValue {
    CGRect frame = self.frame;
    frame.origin.y = bottomValue - frame.size.height;
    self.frame = frame;
}

- (CGFloat)widthValue {
    return self.frame.size.width;
}

- (void)setWidthValue:(CGFloat)widthValue {
    CGRect frame = self.frame;
    frame.size.width = widthValue;
    self.frame = frame;
}

- (CGFloat)heightVlaue {
    return self.frame.size.height;
}

- (void)setHeightVlaue:(CGFloat)heightVlaue {
    CGRect frame = self.frame;
    frame.size.height = heightVlaue;
    self.frame = frame;
}

- (CGFloat)centerXValue {
    return self.center.x;
}

- (void)setCenterXValue:(CGFloat)centerXValue {
    self.center = CGPointMake(centerXValue, self.center.y);
}

- (CGFloat)centerYValue {
    return self.center.y;
}

- (void)setCenterYValue:(CGFloat)centerYValue {
    self.center = CGPointMake(self.center.x, centerYValue);
}

- (void)setSizeValue:(CGSize)sizeValue {
    CGRect frame = self.frame;
    frame.size = sizeValue;
    self.frame = frame;
}

- (CGSize)sizeValue {
    return self.frame.size;
}


@end
