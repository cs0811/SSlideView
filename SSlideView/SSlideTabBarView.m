//
//  SSlideTabBarView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideTabBarView.h"

@interface SSlideTabBarView ()
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
    [self addSubview:self.titleLabel];
    self.titleLabel.frame = self.selfFrame;
    
    self.titleLabel.text = @"12312312";
}

#pragma mark getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel * label = [UILabel new];
        
        _titleLabel = label;
    }
    return _titleLabel;
}

@end
