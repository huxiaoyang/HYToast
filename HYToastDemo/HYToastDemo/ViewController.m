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
        _items = @[@"toast", @"status toast", @"navigation Error toast", @"navigation Info toast", @"navigation Success toast", @"navigation Warning toast"];
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
        [BSToast showToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"status toast"]) {
        [BSToast showStatusToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"navigation Error toast"]) {
        [BSToast showErrorToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"navigation Info toast"]) {
        [BSToast showInfoToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"navigation Success toast"]) {
        [BSToast showSuccessToast:cell.textLabel.text];
    }
    else if ([cell.textLabel.text isEqualToString:@"navigation Warning toast"]) {
        [BSToast showWarningToast:cell.textLabel.text];
    }
}


@end
