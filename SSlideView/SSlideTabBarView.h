//
//  SSlideTabBarView.h
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSlideTabBarViewDelegate <NSObject>

- (void)didSelectedTitleOfIndex:(NSInteger)index;

@end

@interface SSlideTabBarView : UIView

@property (nonatomic, weak) id<SSlideTabBarViewDelegate> delegate;


/**
 滚动到指定标题处

 @param index   index
 */
- (void)scrollToTitleOfIndex:(NSInteger)index;

@end
