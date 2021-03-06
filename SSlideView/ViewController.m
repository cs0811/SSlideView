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
#import "SSlideScrollTabBarView.h"
#import "SSlideTapTabBarView.h"

@interface ViewController ()<SSlideViewDelegate>

@property (nonatomic, strong) TestViewController * test1;
@property (nonatomic, strong) TestViewController * test2;
@property (nonatomic, strong) TestViewController * test3;
@property (nonatomic, strong) TestViewController * test4;
@property (nonatomic, strong) SSlideScrollTabBarView * tabBarView;
@property (nonatomic, strong) UIView * headerView;

@property (nonatomic, strong) SSlideView * slideView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildViewController:self.test1];
    [self addChildViewController:self.test2];
    [self addChildViewController:self.test3];
    [self addChildViewController:self.test4];
    
    [self.tabBarView loadDataWithArr:@[@"测试sdfsdfwesf",@"哈哈哈wefsfwewwe",@"不是sdfweewwer",@"你说sfwevfwefe"]];
    
    _slideView = [[SSlideView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    _slideView.delegate = self;
//    slideView.bouncesEnable = NO;
//    slideView.scrollEnable = NO;
    _slideView.refreshPosition = SSlideViewRefreshPosition_TabBarBottom;
//    _slideView.tabBarOffSetYToTop = 30;
    [self.view addSubview:_slideView];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"refresh" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 300, 60, 30);
    [self.view addSubview:btn];
}

- (void)refresh {
    [self.tabBarView loadDataWithArr:@[@"测试",@"哈哈哈",@"不是sdfweewwer",@"你说sfwevfwefe"]];
}

#pragma mark SSlideViewDelegate 
- (NSInteger)numberOfItemsInSSlideView:(SSlideView *)slideView {
    return self.childViewControllers.count;
}
- (UIScrollView *)slideView:(SSlideView *)slideView itemAtIndex:(NSInteger)index {
    UIScrollView *scrollView = [[self.childViewControllers objectAtIndex:index] tableView];
    return scrollView;
}
- (UIView *)slideView:(SSlideView *)slideView itemSuperViewAtIndex:(NSInteger)index {
    UIView *view = [[self.childViewControllers objectAtIndex:index] view];
    return view;
}
- (SSlideTabBarView *)slideTabBarViewOfSSlideView:(SSlideView *)slideView {
    return self.tabBarView;
}
- (UIView *)slideHeaderViewOfSSlideView:(SSlideView *)slideView {
    return self.headerView;
}
- (void)slideView:(SSlideView *)slideView didScrollToIndex:(NSInteger)index {
    NSLog(@"index -- %ld",index);
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
- (TestViewController *)test3 {
    if (!_test3) {
        TestViewController * vc = [TestViewController new];
        _test3 = vc;
    }
    return _test3;
}
- (TestViewController *)test4 {
    if (!_test4) {
        TestViewController * vc = [TestViewController new];
        _test4 = vc;
    }
    return _test4;
}
- (SSlideScrollTabBarView *)tabBarView {
    if (!_tabBarView) {
        SSlideScrollTabBarView * tabbar = [[SSlideScrollTabBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
        _tabBarView = tabbar;
    }
    return _tabBarView;
}
- (UIView *)headerView {
    if (!_headerView) {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor cyanColor];
        view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 120);
        _headerView = view;
    }
    return _headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
