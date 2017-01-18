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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
- (void)setScrollView:(UIScrollView *)scrollView {
    scrollView.frame = self.bounds;
    _scrollView = scrollView;
}
- (void)setScrollBaseView:(UIView *)scrollBaseView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(removeCurrentScrollViewObserver:)]) {
        if (_scrollView) {
            [self.delegate removeCurrentScrollViewObserver:_scrollView];
        }
    }
    [_scrollBaseView removeFromSuperview];
    scrollBaseView.frame = self.bounds;
    _scrollBaseView = scrollBaseView;
    [self.contentView addSubview:_scrollBaseView];
}

@end
