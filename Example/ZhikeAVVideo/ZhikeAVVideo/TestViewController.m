
//
//  TestViewController.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/15.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "TestViewController.h"
#import "ViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.hidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 150, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"竖屏" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 250, 150, 100)];
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"竖屏，不能转屏" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(100, 350, 150, 100)];
    btn3.backgroundColor = [UIColor yellowColor];
    [btn3 setTitle:@"仅全屏" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    [btn3 addTarget:self action:@selector(click3) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}

- (void)click {
    ViewController *vc = [[ViewController alloc] init];
    vc.shouldAutorotate = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)click2 {
    ViewController *vc = [[ViewController alloc] init];
    vc.shouldAutorotate = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)click3 {
    ViewController *vc = [[ViewController alloc] init];
    vc.isFull = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
