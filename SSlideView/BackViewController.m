//
//  BackViewController.m
//  SSlideView
//
//  Created by tongxuan on 2017/6/7.
//  Copyright © 2017年 tongxuan. All rights reserved.
//

#import "BackViewController.h"
#import "ViewController.h"

@interface BackViewController ()

@end

@implementation BackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"test" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 200, 100, 50);
    [btn addTarget:self action:@selector(goToSlideView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)goToSlideView {
    ViewController *vc = [ViewController new];
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
