//
//  SSlideTabBarView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideTabBarView.h"

@interface SSlideTabBarView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView * titleScroll;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, assign) CGRect selfFrame;
@end

@implementation SSlideTabBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selfFrame = frame;
        [self loadBaseUI];
    }
    return self;
}

#pragma mark loadBaseUI
- (void)loadBaseUI {
    self.backgroundColor = [UIColor orangeColor];
    [self addSubview:self.titleScroll];
    
    [self addSubview:self.titleLabel];
    self.titleLabel.frame = self.selfFrame;
    
    self.titleLabel.text = @"12312312";
}

#pragma mark UIScrollViewDelegate


#pragma mark Action
- (void)scrollToTitleOfIndex:(NSInteger)index {
    
}

#pragma mark getter
- (UIScrollView *)titleScroll {
    if (!_titleScroll) {
        UIScrollView * scroll = [UIScrollView new];
        scroll.frame = self.bounds;
        scroll.delegate = self;
        scroll.showsHorizontalScrollIndicator = NO;
        _titleScroll = scroll;
    }
    return _titleScroll;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel * label = [UILabel new];
        
        _titleLabel = label;
    }
    return _titleLabel;
}

@end
