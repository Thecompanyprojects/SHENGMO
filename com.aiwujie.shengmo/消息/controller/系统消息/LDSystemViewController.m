//
//  LDSystemViewController.m
//  com.aiwujie.shengmo
//
//  Created by a on 17/1/24.
//  Copyright © 2017年 a. All rights reserved.
//

#import "LDSystemViewController.h"

@interface LDSystemViewController ()

@end

@implementation LDSystemViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    if ([self.navigationItem.title isEqualToString:@"系统消息"]) {
       [self scrollToBottomAnimated:YES];
    }else{
        self.conversationMessageCollectionView.frame = CGRectMake(0, 64, WIDTH, HEIGHT - 64);
        [self scrollToBottomAnimated:YES];
        self.chatSessionInputBarControl.hidden = YES;
    }
}

-(void)notifyUpdateUnreadMessageCount
{
    [super notifyUpdateUnreadMessageCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createButton];
    });
}

-(void)createButton{
    UIButton * areaButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 36, 10, 14)];
    if (@available(iOS 11.0, *)) {
        [areaButton setImage:[UIImage imageNamed:@"back-11"] forState:UIControlStateNormal];
    }else{
        [areaButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    }
    [areaButton addTarget:self action:@selector(backButtonOnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:areaButton];
    if (@available(iOS 11.0, *)) {
        leftBarButtonItem.customView.frame = CGRectMake(0, 0, 100, 44);
    }
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

-(void)backButtonOnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
