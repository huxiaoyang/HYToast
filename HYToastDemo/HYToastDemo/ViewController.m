//
//  ViewController.m
//  HYToastDemo
//
//  Created by ucredit-XiaoYang on 16/6/21.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "ViewController.h"
#import "MessagesToast.h"
#import "UIView+BSNotification.h"
#import "UIViewController+Toast.h"
#import <Toast/UIView+Toast.h>
#import <BlocksKit+UIKit.h>


@interface ViewController ()
@property (nonatomic, strong) MessagesToast *toast;

@end

@implementation ViewController {
    NSArray *_items;
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.tableView.rowHeight = 44;
        self.tableView.tableFooterView = [UIView new];
        _items = @[@"toast",
                   @"status toast",
                   @"present UIViewController",
                   @"present UINavigationController",
                   @"notification toast",
                   ];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"toast";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = _items[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"toast"]) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        [keyWindow makeToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"status toast"]) {
        [self showToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"present UIViewController"]) {
        UIViewController *VC = [self nextVC];
        [self presentViewController:VC animated:YES completion:nil];
    }
    else if ([cell.textLabel.text isEqualToString:@"present UINavigationController"]) {
        UINavigationController *VC = [self nextNav];
        [self presentViewController:VC animated:YES completion:nil];
    }
    else if ([cell.textLabel.text isEqualToString:@"notification toast"]) {
        self.toast = [[MessagesToast alloc] init];
        [self.view makeNotification:self.toast duration:1.5];
        
        self.toast.showCompletionBlock = ^(BSNotificationView *view, BOOL finish) {
            NSLog(@"show notification completion --- > %@", view);
        };
        
        self.toast.actionBlock = ^(BSNotificationView *view) {
            NSLog(@"click notification %@", view);
        };
        
        self.toast.hideCompletionBlock = ^(BSNotificationView *view, BOOL finish) {
            NSLog(@"hide notification completion --- > %@", view);
        };
        
    }
}


- (UIViewController *)nextVC {
    UIViewController *VC = [[UIViewController alloc] init];
    VC.edgesForExtendedLayout = UIRectEdgeNone;
    VC.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"click me" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    CGRect rect;
    rect.origin = CGPointMake((screenW - 100)/2, (screenH - 50)/2);
    rect.size = CGSizeMake(100, 50);
    button.frame = rect;
    [VC.view addSubview:button];

    [button bk_addEventHandler:^(id sender) {
        
        [VC showToast:@"newVC"];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setBackgroundColor:[UIColor redColor]];
    [back setTitle:@"back" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    back.frame = CGRectMake(20, 20, 50, 30);
    [VC.view addSubview:back];

    [back bk_addEventHandler:^(id sender) {
        [VC dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return VC;
}

- (UINavigationController *)nextNav {
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[self nextVC]];
    return nav;
}

@end
