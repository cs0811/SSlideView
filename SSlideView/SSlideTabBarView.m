//
//  SSlideTabBarView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideTabBarView.h"

@interface SSlideTabBarView ()
@end

@implementation SSlideTabBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadBaseUI];
    }
    return self;
}

#pragma mark loadBaseUI
- (void)loadBaseUI {
    
}

#pragma mark Action
- (void)scrollToTitleAtIndex:(NSInteger)index {
    // need to overwrite
}

@end
