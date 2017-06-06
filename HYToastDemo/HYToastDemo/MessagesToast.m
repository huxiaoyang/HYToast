//
//  MessagesToast.m
//  HYToastDemo
//
//  Created by ucredit-XiaoYang on 2017/6/5.
//  Copyright © 2017年 XiaoYang. All rights reserved.
//

#import "MessagesToast.h"

@implementation MessagesToast

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect frame = self.frame;
        frame .size = CGSizeMake(300, 100);
        self.frame = frame;
        
        int i = arc4random() % 255;
        int j = arc4random() % 255;
        int k = arc4random() % 255;
        self.backgroundColor = [UIColor colorWithRed:i/255.0 green:j/255 blue:k/255 alpha:1];
        
        self.layer.cornerRadius = 10;
        [self clipsToBounds];
        
    }
    return self;
}

@end
