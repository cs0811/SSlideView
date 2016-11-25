//
//  SSlideScrollTabBarView.h
//  SSlideView
//
//  Created by tongxuan on 16/11/25.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideTabBarView.h"

@interface SSlideScrollTabBarView : SSlideTabBarView

/**
 左右不移动的标题个数    (默认 1)
 */
@property (nonatomic, assign) NSInteger countOfTitleMiddleUnAble;

@property (nonatomic, strong) UIColor * unSelectedTitleColor;
@property (nonatomic, strong) UIColor * selectedTitleColor;
@property (nonatomic, strong) UIFont * titleFont;


- (void)loadDataWithArr:(NSArray *)arr;

@end
