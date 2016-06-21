//
//  ViewController.m
//  HYToastDemo
//
//  Created by ucredit-XiaoYang on 16/6/21.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "ViewController.h"
#import "BSToast.h"


@interface ViewController ()

@end

@implementation ViewController {
    NSArray *_items;
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.tableView.rowHeight = 44;
        self.tableView.tableFooterView = [UIView new];
        _items = @[@"toast", @"navigation bar toast", @"status toast"];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"toast";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


/**
 *  如果调用showStatusToast：方法，重写下面两个方法并给bs_isViewAppear赋值
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.bs_isViewAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.bs_isViewAppear = NO;
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
        [BSToast showToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"navigation bar toast"]) {
        [BSToast showToastNotificationStyle:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"status toast"]) {
        [BSToast showStatusToast:cell.textLabel.text];
    }
}


@end
