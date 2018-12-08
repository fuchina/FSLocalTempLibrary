//
//  ViewController.m
//  FSAccountSample
//
//  Created by FudonFuchina on 2018/12/8.
//  Copyright © 2018年 FudonFuchina. All rights reserved.
//

#import "ViewController.h"
#import "FSBestAccountController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 100, UIScreen.mainScreen.bounds.size.width - 20, 50)];
    view.backgroundColor = UIColor.brownColor;
    [self.view addSubview:view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [view addGestureRecognizer:tap];
}

- (void)click{
    FSBestAccountController *i = [[FSBestAccountController alloc] init];
    i.table = @"ab_yi";
    i.title = @"2018";
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:i];
    [self presentViewController:navi animated:YES completion:nil];
}


@end
