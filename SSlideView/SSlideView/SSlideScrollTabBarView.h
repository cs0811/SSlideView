//
//  SSlideScrollTabBarView.h
//  SSlideView
//
//  Created by tongxuan on 16/11/25.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideTabBarView.h"

@interface SSlideScrollTabBarView : SSlideTabBarView

@property (nonatomic, strong) UIColor * unSelectedTitleColor;
@property (nonatomic, strong) UIColor * selectedTitleColor;
@property (nonatomic, strong) UIFont * titleFont;


- (void)loadDataWithArr:(NSArray *)arr;

@end
