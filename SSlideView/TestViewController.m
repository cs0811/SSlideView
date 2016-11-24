//
//  TestViewController.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadUI];
}

- (void)loadUI {
    [self.view addSubview:self.tableView];
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
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"index -- %ld",indexPath.row);
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
