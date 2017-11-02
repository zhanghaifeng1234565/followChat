//
//  BaseViewController.m
//  weChatDemoRongCloud
//
//  Created by iOS on 2017/10/31.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"HomeViewController";
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.view addSubview:addBtn];
    addBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-50)/2, ([UIScreen mainScreen].bounds.size.height-50)/2, 50, 50);
    
    [addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchDown];
    
}

- (void)addBtnClick {
    
    ViewController *vc = [[ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
