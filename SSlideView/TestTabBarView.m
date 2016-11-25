//
//  TestTabBarView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/25.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "TestTabBarView.h"

#define kWidth      60.

#define kLeftSpace      10.
#define kRightSpace     10.
// 水平间距
#define kSpaceH         10.

#define kTag            1024

@interface TestTabBarView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView * scroll;
@property (nonatomic, strong) NSMutableArray * titleArr;
@end

@implementation TestTabBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadUI];
    }
    return self;
}

#pragma mark loadUI
- (void)loadUI {
    [self addSubview:self.scroll];
    self.scroll.frame = self.frame;
    
}

- (void)loadDataWithArr:(NSArray *)arr {
    self.titleArr = [NSMutableArray arrayWithCapacity:arr.count];

    UIView * lastView = nil;
    for (int i=0; i<arr.count; i++) {
        UIButton * label = [UIButton buttonWithType:UIButtonTypeCustom];
        [label setTitle:arr[i] forState:UIControlStateNormal];
        label.titleLabel.font = [UIFont systemFontOfSize:14.];
        label.selected = NO;
        [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [label setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [label addTarget:self action:@selector(scrollToTitle:) forControlEvents:UIControlEventTouchUpInside];
        label.tag = kTag+i;
        [self.scroll addSubview:label];
        
        CGRect frame = CGRectZero;
        if (!lastView) {
            frame = CGRectMake(kLeftSpace, 2, kWidth, CGRectGetHeight(self.scroll.frame));
            label.selected = YES;
        }else {
            frame = CGRectMake(CGRectGetMaxX(lastView.frame)+kSpaceH, CGRectGetMinY(lastView.frame), kWidth, CGRectGetHeight(lastView.frame));
        }
        label.frame = frame;
        lastView = label;
        [self.titleArr addObject:label];
    }
    self.scroll.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame)+kRightSpace, self.frame.size.height);
}

#pragma mark UIScrollViewDelegate 
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.y/(kLeftSpace);
    [self slideViewScrollToIndex:index];
}

#pragma mark Action
- (void)scrollToTitleAtIndex:(NSInteger)index {
    // need to overwrite
    for (UIButton * btn  in self.titleArr) {
        if (btn.selected) {
            btn.selected = NO;
        }
    }
    
    UIButton * btn = self.titleArr[index];
    btn.selected = YES;
}

- (void)scrollToTitle:(UIButton *)sender {
    NSInteger index = sender.tag-kTag;
    [self scrollToTitleAtIndex:index];
    [self slideViewScrollToIndex:index];
}

- (void)slideViewScrollToIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(slideTabBar:didSelectedTitleOfIndex:)]) {
        [self.delegate slideTabBar:self didSelectedTitleOfIndex:index];
    }
}

#pragma mark getter
- (UIScrollView *)scroll {
    if (!_scroll) {
        UIScrollView * view = [UIScrollView new];
        view.backgroundColor = [UIColor orangeColor];
        view.delegate = self;
        _scroll = view;
    }
    return _scroll;
}

@end
