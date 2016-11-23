//
//  ViewController.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "ViewController.h"
#import "SSlideView.h"
#import "TestViewController.h"

@interface ViewController ()<SSlideViewDelegate>

@property (nonatomic, strong) TestViewController * test1;
@property (nonatomic, strong) TestViewController * test2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildViewController:self.test1];
    [self addChildViewController:self.test2];
    
    SSlideView * slideView = [[SSlideView alloc] initWithFrame:self.view.frame];
    slideView.delegate = self;
    [self.view addSubview:slideView];
}

#pragma mark SSlideViewDelegate 
- (NSInteger)numberOfItemsInSSlideView:(SSlideView *)slideView {
    return self.childViewControllers.count;
}
- (UIScrollView *)slideView:(SSlideView *)slideView itemAtIndex:(NSInteger)index {
    UIScrollView *scrollView = [[self.childViewControllers objectAtIndex:index] tableView];
    return scrollView;
}


#pragma mark getter
- (TestViewController *)test1 {
    if (!_test1) {
        TestViewController * vc = [TestViewController new];
        _test1 = vc;
    }
    return _test1;
}
- (TestViewController *)test2 {
    if (!_test2) {
        TestViewController * vc = [TestViewController new];
        _test2 = vc;
    }
    return _test2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
