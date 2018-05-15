//
//  ViewController.m
//  HYToastDemo
//
//  Created by ucredit-XiaoYang on 16/6/21.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "ViewController.h"
#import "UIWindow+BSNotification.h"
#import "BSStatusToastManager.h"
#import "MessagesToast.h"


@interface ViewController ()

@property (nonatomic, strong) MessagesToast *toast;
@property (nonatomic, strong) UIViewController *presentVC;

@end


@implementation ViewController {
    NSArray *_items;
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.tableView.rowHeight = 44;
        self.tableView.tableFooterView = [UIView new];
        _items = @[@"status toast",
                   @"push UIViewController",
                   @"push UIViewController HideBar",
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
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
    if ([cell.textLabel.text isEqualToString:@"status toast"]) {
        showStatusToast(cell.textLabel.text);
    }
    else if ([cell.textLabel.text isEqualToString:@"push UIViewController"]) {
        self.presentVC = [self nextVC];
        [self.navigationController pushViewController:_presentVC animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"present UIViewController"]) {
        self.presentVC = [self nextVC];
        [self presentViewController:_presentVC animated:YES completion:nil];
    }
    else if ([cell.textLabel.text isEqualToString:@"present UINavigationController"]) {
        self.presentVC = [self nextNav];
        [self presentViewController:_presentVC animated:YES completion:nil];
    }
    else if ([cell.textLabel.text isEqualToString:@"push UIViewController HideBar"]) {
        self.presentVC = [self nextVC];
        self.navigationController.navigationBar.hidden = YES;
        [self.navigationController pushViewController:_presentVC animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"notification toast"]) {
        self.toast = [[MessagesToast alloc] init];
        showNotificationToast(self.toast);
        
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
    button.tag = 1000;
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
    
    [button addTarget:self action:@selector(pr_clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.tag = 2000;
    [back setBackgroundColor:[UIColor redColor]];
    [back setTitle:@"back" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    back.frame = CGRectMake(20, 20, 50, 30);
    [VC.view addSubview:back];
    
    [back addTarget:self action:@selector(pr_clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return VC;
}

- (UINavigationController *)nextNav {
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[self nextVC]];
    return nav;
}

- (void)pr_clickButton:(UIButton *)button {
    if (button.tag == 1000) {
        showStatusToast(@"newVC");
    } else {
        if (self.presentVC.navigationController) {
            [self.presentVC.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.presentVC dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
