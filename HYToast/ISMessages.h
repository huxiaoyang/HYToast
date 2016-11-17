//
//  ISMessages.h
//  ISMessages
//
//  Created by Ilya Inyushin on 08.09.16.
//  Copyright © 2016 Ilya Inyushin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ISMessagesStyle;


typedef NS_ENUM(NSInteger, ISAlertType) {
    // Green alert view with check mark image.
    ISAlertTypeSuccess = 0,
    // Red alert view with error image
    ISAlertTypeError = 1,
    // Orange alert view with warning image
    ISAlertTypeWarning = 2,
    // Light green alert with info image.
    ISAlertTypeInfo = 3,
};

typedef NS_ENUM(NSInteger, ISAlertPosition) {
    // Alert will show from top
    ISAlertPositionTop = 0,
    // Alert will show from bottom
    ISAlertPositionBottom = 1
};

@interface ISMessages : UIViewController

@property (assign, nonatomic) CGFloat messageLabelHeight;
@property (assign, nonatomic) CGFloat alertViewHeight;

@property (nonatomic, copy) NSString* titleString;
@property (nonatomic, copy) NSString* messageString;

/**
 @author Ilya Inyushin
 
 Method is show card alert view
 
 @param title Title for alert view
 @param message Subtitle for alertview, can be empty and nil
 @param type alert type
 */
+ (instancetype)showISMessageToastWithTitle:(NSString *)title
                                    message:(NSString *)message
                                  alertType:(ISAlertType)type
                                      style:(ISMessagesStyle *)style;

/**
 @author Ilya Inyushin
 
 Method is hide alert view
 
 @param animated @(YES/NO) animated hide
 */

+ (void)hideAlertAnimated:(BOOL)animated;


@end


@interface ISMessagesStyle : NSObject

@property (nonatomic, assign) CGSize iconImageSize;

@property (nonatomic, assign) BOOL hideOnSwipe;
@property (nonatomic, assign) BOOL hideOnTap;
@property (nonatomic, assign) ISAlertPosition alertPosition;

@property (nonatomic, strong) UIColor* titleLabelTextColor;
@property (nonatomic, strong) UIColor* messageLabelTextColor;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, strong) UIColor *alertViewBackgroundSuccessColor;
@property (nonatomic, strong) UIColor *alertViewBackgroundErrorColor;
@property (nonatomic, strong) UIColor *alertViewBackgroundWarningColor;
@property (nonatomic, strong) UIColor *alertViewBackgroundInfoColor;

@property (nonatomic, strong) UIImage *iconSuccessImage;
@property (nonatomic, strong) UIImage *iconErrorImage;
@property (nonatomic, strong) UIImage *iconWarningImage;
@property (nonatomic, strong) UIImage *iconInfoImage;

- (instancetype)initWithISMessagesDefaultStyle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end
