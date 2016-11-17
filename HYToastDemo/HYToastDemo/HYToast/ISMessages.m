//
//  ISMessages.m
//  ISMessages
//
//  Created by Ilya Inyushin on 08.09.16.
//  Copyright © 2016 Ilya Inyushin. All rights reserved.
//

#import "ISMessages.h"

static CGFloat const kDefaultCardViewHeight = 51.f;
static CGFloat const kDefaulInset = 8.f;
static CGFloat const kTitleLabelHeight = 18.f;


@interface ISMessages ()

@property (nonatomic, strong) ISMessagesStyle *style;

@property (strong, nonatomic) UIColor* alertViewBackgroundColor;
@property (strong, nonatomic) UIImage* iconImage;

@end

@implementation ISMessages

static NSMutableArray* currentAlertArray = nil;

+ (instancetype)showISMessageToastWithTitle:(NSString *)title
                                    message:(NSString *)message
                                  alertType:(ISAlertType)type
                                      style:(ISMessagesStyle *)style {
    
    ISMessages *alert = [[ISMessages alloc] initISMessageToastWithTitle:title
                                                                message:message
                                                              alertType:type
                                                                  style:style];
    [alert show];
    return alert;
}

- (instancetype)initISMessageToastWithTitle:(NSString *)title
                                    message:(NSString *)message
                                  alertType:(ISAlertType)type
                                      style:(ISMessagesStyle *)style {
    self = [super init];
    if (self) {
        
        self.style = style ?: [[ISMessagesStyle alloc] initWithISMessagesDefaultStyle];
        
        if (!currentAlertArray) {
            currentAlertArray = [NSMutableArray new];
        }
        
        if (!title || title.length == 0) {
            self.titleString = nil;
        } else {
            self.titleString = title;
        }
        
        self.messageString = message;
        [self configureViewForAlertType:type];
        self.messageLabelHeight = ceilf([self preferredHeightForMessageString:_messageString]);
        
        if (!title || title.length == 0) {
            self.alertViewHeight = kDefaulInset + 3.f + _messageLabelHeight + 8.f;
        } else {
            self.alertViewHeight = kDefaulInset + kTitleLabelHeight + 3.f + _messageLabelHeight + 8.f;
        }
        if (_alertViewHeight < kDefaultCardViewHeight) {
            self.alertViewHeight = kDefaultCardViewHeight;
        }
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat alertYPosition = screenHeight - (_alertViewHeight + screenHeight);
    
    if (self.style.alertPosition == ISAlertPositionBottom) {
        alertYPosition = screenHeight + _alertViewHeight;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, screenWidth - (kDefaulInset*2.f), _alertViewHeight);
    
    self.view.alpha = 0.7f;
    self.view.layer.cornerRadius = 7.f;
    self.view.layer.masksToBounds = YES;
    [self constructAlertCardView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self hide:@(YES)];
}

- (void)constructAlertCardView {
    
    UIView* alertView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
    alertView.backgroundColor = _alertViewBackgroundColor;
    [self.view addSubview:alertView];
    
    UIImageView* iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kDefaulInset, (_alertViewHeight - self.style.iconImageSize.height) / 2.f, self.style.iconImageSize.width, self.style.iconImageSize.height)];
    iconImageView.image = _iconImage;
    [alertView addSubview:iconImageView];
    
    if (self.titleString && self.titleString.length != 0) {
        UILabel* titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake((kDefaulInset*2.f) + self.style.iconImageSize.width, kDefaulInset, self.view.frame.size.width - ((kDefaulInset*3.f) + self.style.iconImageSize.width), kTitleLabelHeight);
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 1.f;
        titleLabel.textColor = self.style.titleLabelTextColor;
        titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
        titleLabel.text = _titleString;
        [alertView addSubview:titleLabel];
    }
    
    UILabel* messageLabel = [UILabel new];
    if (self.titleString && self.titleString.length != 0) {
        messageLabel.frame = CGRectMake((kDefaulInset*2.f) + self.style.iconImageSize.width, kDefaulInset + kTitleLabelHeight + 3.f, self.view.frame.size.width - ((kDefaulInset*3.f) + self.style.iconImageSize.width), _messageLabelHeight);
    } else {
        messageLabel.frame = CGRectMake((kDefaulInset*2.f) + self.style.iconImageSize.width, (_alertViewHeight - _messageLabelHeight) / 2.f, self.view.frame.size.width - ((kDefaulInset*3.f) + self.style.iconImageSize.width), _messageLabelHeight);
    }
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.numberOfLines = 0.f;
    messageLabel.textColor = self.style.messageLabelTextColor;
    messageLabel.font = [UIFont systemFontOfSize:15.f];
    messageLabel.text = _messageString;
    [alertView addSubview:messageLabel];
    
    if (self.style.hideOnSwipe) {
        UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
        [alertView addGestureRecognizer:swipeGesture];
    }
    
    if (self.style.hideOnTap) {
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction)];
        [alertView addGestureRecognizer:tapGesture];
    }
    
}

- (void)show {
    [self performSelectorOnMainThread:@selector(showInMain) withObject:nil waitUntilDone:NO];
}

- (void)showInMain {
    
    if ([currentAlertArray count] != 0) {
        [self performSelectorOnMainThread:@selector(hide:) withObject:@(YES) waitUntilDone:YES];
    }
    
    @synchronized (currentAlertArray) {
        
        [([UIApplication sharedApplication].delegate).window addSubview:self.view];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat alertYPosition = 20.f;
        
        if (self.style.alertPosition == ISAlertPositionBottom) {
            alertYPosition = screenHeight - _alertViewHeight - 10.f;
        }
        
        [UIView animateWithDuration:0.7f
                              delay:0.f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.5f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, screenWidth - (kDefaulInset*2.f), _alertViewHeight);
                             self.view.alpha = 1.f;
                         } completion:^(BOOL finished) {
                             self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, screenWidth - (kDefaulInset*2.f), _alertViewHeight);
                             self.view.alpha = 1.f;
                         }];
        
        [currentAlertArray addObject:self];
        
        [self performSelector:@selector(hide:) withObject:@(NO) afterDelay:self.style.duration];
        
    }
    
}

- (void)hide:(NSNumber*)force {
    if (force.boolValue == YES) {
        [self forceHideInMain];
    } else {
        [self hideInMain];
    }
}

- (void)gestureAction {
    [self hide:@(NO)];
}

#pragma mark - Private Methods

- (void)hideInMain {
    
    if ([currentAlertArray containsObject:self]) {
        @synchronized (currentAlertArray) {
            
            [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
            [currentAlertArray removeObject:self];
            
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat alertYPosition = -_alertViewHeight;
            
            if (self.style.alertPosition == ISAlertPositionBottom) {
                alertYPosition = screenHeight;
            }
            
            [UIView animateWithDuration:0.3f animations:^{
                self.view.alpha = 0.7;
                self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, self.view.frame.size.width, self.view.frame.size.height);
            } completion:^(BOOL finished) {
                self.view.alpha = 0.7;
                self.view.frame = CGRectMake((kDefaulInset*2.f)/2.f, alertYPosition, self.view.frame.size.width, self.view.frame.size.height);
                [self.view removeFromSuperview];
            }];
            
        }
    }
    
}

- (void)forceHideInMain {
    
    if (currentAlertArray && [currentAlertArray count] > 0) {
        @synchronized (currentAlertArray) {
            
            ISMessages* activeAlert = currentAlertArray[0];
            [NSRunLoop cancelPreviousPerformRequestsWithTarget:activeAlert];
            [currentAlertArray removeObject:activeAlert];
            
            [UIView animateWithDuration:0.1f
                             animations:^{
                                 activeAlert.view.alpha = 0.f;
                             } completion:^(BOOL finished) {
                                 [activeAlert.view removeFromSuperview];
                             }];
            
        }
    }
    
}

+ (void)hideAlertAnimated:(BOOL)animated {
    
    if (currentAlertArray && [currentAlertArray count] != 0) {
        ISMessages* alert = currentAlertArray[0];
        [alert hide:[NSNumber numberWithBool:!animated]];
    }

}

- (CGFloat)preferredHeightForMessageString:(NSString*)message {
    
    if (!message || message.length == 0) {
        return ceilf(0.f);
    }
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat messageHeight = [message boundingRectWithSize:CGSizeMake(screenWidth - 40.f - self.style.iconImageSize.height, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSParagraphStyleAttributeName : paragraphStyle,
                                                            NSFontAttributeName : [UIFont systemFontOfSize:15.f]}
                                                  context:nil].size.height;
    
    return ceilf(messageHeight);
    
}

- (UIImage*)imageNamed:(NSString*)name {
    NSBundle * pbundle = [NSBundle bundleForClass:[self class]];
    NSString *bundleURL = [pbundle pathForResource:@"ISMessages" ofType:@"bundle"];
    NSBundle *imagesBundle = [NSBundle bundleWithPath:bundleURL];
    UIImage * image = [UIImage imageNamed:name inBundle:imagesBundle compatibleWithTraitCollection:nil];
    return image;
}

- (void)configureViewForAlertType:(ISAlertType)alertType {
    
    switch (alertType) {
        case ISAlertTypeSuccess: {
            self.alertViewBackgroundColor = self.style.alertViewBackgroundSuccessColor ?: [UIColor colorWithRed:31.f/255.f green:177.f/255.f blue:138.f/255.f alpha:1.f];
            self.iconImage = self.style.iconSuccessImage ?: [self imageNamed:@"isSuccessIcon"];
            break;
        }
        case ISAlertTypeError: {
            self.alertViewBackgroundColor = self.style.alertViewBackgroundErrorColor ?: [UIColor colorWithRed:255.f/255.f green:91.f/255.f blue:65.f/255.f alpha:1.f];
            self.iconImage = self.style.iconErrorImage ?: [self imageNamed:@"isErrorIcon"];
            break;
        }
        case ISAlertTypeWarning: {
            self.alertViewBackgroundColor = self.style.alertViewBackgroundWarningColor ?: [UIColor colorWithRed:255.f/255.f green:134.f/255.f blue:0.f/255.f alpha:1.f];
            self.iconImage = self.style.iconWarningImage ?: [self imageNamed:@"isWarningIcon"];
            break;
        }
        case ISAlertTypeInfo: {
            self.alertViewBackgroundColor = self.style.alertViewBackgroundInfoColor ?: [UIColor colorWithRed:75.f/255.f green:107.f/255.f blue:122.f/255.f alpha:1.f];
            self.iconImage = self.style.iconInfoImage ?: [self imageNamed:@"isInfoIcon"];
            break;
        }
        default:
            break;
    }
    
    
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


@end


@implementation ISMessagesStyle

- (instancetype)initWithISMessagesDefaultStyle {
    self = [super init];
    if (self) {
        
        self.duration = 3.f;
        self.hideOnTap = YES;
        self.hideOnSwipe = YES;
        self.iconImageSize = CGSizeMake(35.f, 35.f);
        self.alertPosition = ISAlertPositionTop;
        self.titleLabelTextColor = [UIColor whiteColor];
        self.messageLabelTextColor = [UIColor whiteColor];
        
        self.iconInfoImage = nil;
        self.iconWarningImage = nil;
        self.iconErrorImage = nil;
        self.iconSuccessImage = nil;
        
        self.alertViewBackgroundInfoColor = nil;
        self.alertViewBackgroundWarningColor = nil;
        self.alertViewBackgroundErrorColor = nil;
        self.alertViewBackgroundSuccessColor = nil;
        
    }
    return self;
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end

