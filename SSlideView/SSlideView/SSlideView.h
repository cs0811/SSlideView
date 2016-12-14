//
//  SSlideView.h
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSlideTabBarView.h"


@class SSlideView;
@protocol SSlideViewDelegate <NSObject>

- (NSInteger)numberOfItemsInSSlideView:(SSlideView *)slideView;
- (UIScrollView *)slideView:(SSlideView *)slideView itemAtIndex:(NSInteger)index;
- (UIView *)slideView:(SSlideView *)slideView itemSuperViewAtIndex:(NSInteger)index;
- (SSlideTabBarView *)slideTabBarViewOfSSlideView:(SSlideView *)slideView;

@optional
- (UIView *)slideHeaderViewOfSSlideView:(SSlideView *)slideView;
- (void)slideView:(SSlideView *)slideView didScrollToIndex:(NSInteger)index;

@end

@interface SSlideView : UIView

/**
 是否在最顶部刷新       (默认 YES)
 */
@property (nonatomic, assign) BOOL refreshAtTabBarViewTop;

@property (nonatomic, weak) id<SSlideViewDelegate> delegate;

@end
