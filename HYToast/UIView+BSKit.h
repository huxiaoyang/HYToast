//
//  UIView+BSKit.h
//  StarterKit
//
//  Created by XiaoYang on 15/10/13.
//  Copyright © 2015年 XiaoYang. All rights reserved.
//

#import <UIKit/UIKit.h>


// 常量
#define Screen_width  [[UIScreen mainScreen] bounds].size.width
#define Screen_height  [[UIScreen mainScreen] bounds].size.height


@interface UIView (BSKit)

@property (nonatomic, assign) CGFloat leftValue;
@property (nonatomic, assign) CGFloat rightValue;
@property (nonatomic, assign) CGFloat topValue;
@property (nonatomic, assign) CGFloat bottomValue;
@property (nonatomic, assign) CGFloat widthValue;
@property (nonatomic, assign) CGFloat heightVlaue;
@property (nonatomic, assign) CGFloat centerXValue;
@property (nonatomic, assign) CGFloat centerYValue;
@property (nonatomic, assign) CGSize sizeValue;


@end
