//
//  UIScrollView+SSlideViewAddition.m
//  SSlideView
//
//  Created by tongxuan on 16/11/24.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "UIScrollView+SSlideViewAddition.h"
#import <objc/runtime.h>

const char kTabBarHasStatic;

@implementation UIScrollView (SSlideViewAddition)


#pragma mark getter
- (BOOL)tabBarHasStatic {
    return [objc_getAssociatedObject(self, &kTabBarHasStatic) boolValue];
}

- (void)setTabBarHasStatic:(BOOL)tabBarHasStatic {
    objc_setAssociatedObject(self, &kTabBarHasStatic, @(tabBarHasStatic), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
