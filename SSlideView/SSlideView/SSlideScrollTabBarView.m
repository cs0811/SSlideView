//
//  SSlideScrollTabBarView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/25.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideScrollTabBarView.h"

#define kLeftSpace      10.
#define kRightSpace     10.
// 水平间距
#define kSpaceH         10.

#define kTag            1024

@interface SSlideScrollTabBarView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView * scroll;
@property (nonatomic, strong) NSMutableArray * titleArr;
@property (nonatomic, strong) UIView * lineView;
@end

@implementation SSlideScrollTabBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadUI];
    }
    return self;
}

#pragma mark loadUI
- (void)loadUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scroll];
    self.scroll.frame = self.frame;
    [self addSubview:self.lineView];
    self.lineView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-0.5, CGRectGetWidth(self.frame), 0.5);
    
    _countOfTitleMiddleUnAble = 1;
}

- (void)loadDataWithArr:(NSArray *)arr {
    self.titleArr = [NSMutableArray arrayWithCapacity:arr.count];
    
    UIView * lastView = nil;
    for (int i=0; i<arr.count; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString * title = arr[i];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = _titleFont?:[UIFont systemFontOfSize:14.];
        btn.selected = NO;
        [btn setTitleColor:_unSelectedTitleColor?:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:_selectedTitleColor?:[UIColor redColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = kTag+i;
        [self.scroll addSubview:btn];
        
        CGFloat height = CGRectGetHeight(self.scroll.frame);
        CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font} context:nil].size;
        
        CGRect frame = CGRectZero;
        if (!lastView) {
            frame = CGRectMake(kLeftSpace, 2, size.width, height);
            btn.selected = YES;
        }else {
            frame = CGRectMake(CGRectGetMaxX(lastView.frame)+kSpaceH, CGRectGetMinY(lastView.frame), size.width, height);
        }
        btn.frame = frame;
        lastView = btn;
        [self.titleArr addObject:btn];
    }
    self.scroll.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame)+kRightSpace, self.frame.size.height);
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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
    [self middleTitleAtIndex:index];
}

- (void)titleClick:(UIButton *)sender {
    NSInteger index = sender.tag-kTag;
    [self scrollToTitleAtIndex:index];
    [self slideViewScrollToIndex:index];
    [self middleTitleAtIndex:index];
}

- (void)middleTitleAtIndex:(NSInteger)index {
    
    if (index<_countOfTitleMiddleUnAble) {
        return;
    }
    if (index>self.titleArr.count-1-_countOfTitleMiddleUnAble) {
        return;
    }
    
    UIButton * btn = self.titleArr[index];
    CGFloat btnMiddle = CGRectGetMidX(btn.frame);
    CGFloat screenMiddle = self.scroll.contentOffset.x+self.scroll.frame.size.width/2;
    CGFloat offX = btnMiddle - screenMiddle;
    
    CGFloat currentOffX = self.scroll.contentOffset.x;
    [self.scroll setContentOffset:CGPointMake(currentOffX+offX, 0) animated:YES];
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
        view.showsHorizontalScrollIndicator = NO;
        view.delegate = self;
        _scroll = view;
    }
    return _scroll;
}
- (UIView *)lineView {
    if (!_lineView) {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor lightGrayColor];
        _lineView = view;
    }
    return _lineView;
}

@end
