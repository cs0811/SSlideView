//
//  SSlideTabBarView.h
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSlideTabBarBtn : UIButton
@end

@class SSlideTabBarView;

@protocol SSlideTabBarViewDelegate <NSObject>

/**
 选中了指定title (需要内部调用，以通知SlideView滚动到指定位置)
 */
- (void)slideTabBar:(SSlideTabBarView *)slideTabBar didSelectedTitleOfIndex:(NSInteger)index;

@end

@interface SSlideTabBarView : UIView

@property (nonatomic, weak) id<SSlideTabBarViewDelegate> delegate;


/**
 滚动到指定title处

 @param index   need to overwrite
 */
- (void)scrollToTitleAtIndex:(NSInteger)index;

@end
