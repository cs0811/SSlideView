//
//  SSlideTapTabBarView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/25.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideTapTabBarView.h"

// 水平间距
#define kSpaceH         40.
#define kWidth          80.

#define kTag            2048

@interface SSlideTapTabBarView ()
@property (nonatomic, strong) NSMutableArray * titleArr;
@property (nonatomic, strong) UIView * lineView;
@end

@implementation SSlideTapTabBarView


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
    [self addSubview:self.lineView];
    self.lineView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-0.5, CGRectGetWidth(self.frame), 0.5);
    
}

- (void)loadDataWithArr:(NSArray *)arr {
    self.titleArr = [NSMutableArray arrayWithCapacity:arr.count];
    [self removeAllBtns];

    UIView * lastView = nil;
    for (int i=0; i<arr.count; i++) {
        SSlideTabBarBtn * btn = [SSlideTabBarBtn buttonWithType:UIButtonTypeCustom];
        NSString * title = arr[i];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = _titleFont?:[UIFont systemFontOfSize:14.];
        btn.selected = NO;
        [btn setTitleColor:_unSelectedTitleColor?:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:_selectedTitleColor?:[UIColor redColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = kTag+i;
        [self addSubview:btn];
        
        CGFloat height = CGRectGetHeight(self.frame);
//        CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font} context:nil].size;
//        
        
        CGFloat leftSpace = (CGRectGetWidth(self.frame)-(arr.count-1)*kSpaceH-arr.count*kWidth)/2.;
        CGRect frame = CGRectZero;
        if (!lastView) {
            frame = CGRectMake(leftSpace, 2, kWidth, height);
            btn.selected = YES;
        }else {
            frame = CGRectMake(CGRectGetMaxX(lastView.frame)+kSpaceH, CGRectGetMinY(lastView.frame), kWidth, height);
        }
        btn.frame = frame;
        lastView = btn;
        [self.titleArr addObject:btn];
    }
}

- (void)removeAllBtns {
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[SSlideTabBarBtn class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark Action
- (void)didClickTabAtIndex:(NSInteger)index {
    if (index > self.titleArr.count - 1) {
        return;
    }
    
    SSlideTabBarBtn * btn = self.titleArr[index];
    [self titleClick:btn];
}

- (void)scrollToTitleAtIndex:(NSInteger)index {
    // need to overwrite
    for (SSlideTabBarBtn * btn  in self.titleArr) {
        if (btn.selected) {
            btn.selected = NO;
        }
    }
    
    SSlideTabBarBtn * btn = self.titleArr[index];
    btn.selected = YES;
}

- (void)titleClick:(SSlideTabBarBtn *)sender {
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
- (UIView *)lineView {
    if (!_lineView) {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor lightGrayColor];
        _lineView = view;
    }
    return _lineView;
}

@end
