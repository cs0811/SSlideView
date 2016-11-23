//
//  SSlideView.h
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSlideView;
@protocol SSlideViewDelegate <NSObject>

- (NSInteger)numberOfItemsInSSlideView:(SSlideView *)slideView;
- (UIScrollView *)slideView:(SSlideView *)slideView itemAtIndex:(NSInteger)index;


@optional

@end

@interface SSlideView : UIView

@property (nonatomic, weak) id<SSlideViewDelegate> delegate;

@end
