//
//  TestViewController.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "TestViewController.h"
#import "MJRefresh.h"
#import "ViewController.h"

@interface TestViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadUI];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)loadUI {
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self performSelector:@selector(cancelRefreh) withObject:nil afterDelay:1];
        
    }];
//    self.tableView.mj_header.ignoredScrollViewContentInsetTop = 160;
    [self.tableView.mj_header layoutSubviews];

}

- (void)cancelRefreh {
    [self.tableView.mj_header endRefreshing];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    // 判断能否使用 peek功能
    if ([self respondsToSelector:@selector(traitCollection)]) {
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selectedIndex -- %ld",indexPath.row);
}

#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    ViewController * vc = [ViewController new];
    return vc;
}

#pragma mark getter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        table.delegate = self;
        table.dataSource = self;
        table.rowHeight = 50;
        [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        
        _tableView = table;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
