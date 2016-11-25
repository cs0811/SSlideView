//
//  SSlideViewCollectionCell.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideViewCollectionCell.h"

@interface SSlideViewCollectionCell ()

@end

@implementation SSlideViewCollectionCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadBaseUI];
    }
    return self;
}

#pragma mark loadBaseUI
- (void)loadBaseUI {
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark getter
- (void)setTableView:(UITableView *)tableView {
    tableView.frame = self.bounds;
    _tableView = tableView;
    [self addSubview:_tableView];
}

@end
