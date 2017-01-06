//
//  SSlideViewCollectionCell.h
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * kSSlideViewCollectionCell = @"SSlideViewCollectionCell";

@protocol SSlideViewCollectionCellDelegate <NSObject>

- (void)removeCurrentScrollViewObserver:(UIScrollView *)scrollView;

@end

@interface SSlideViewCollectionCell : UICollectionViewCell

@property (nonatomic, weak) id<SSlideViewCollectionCellDelegate> delegate;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UIView * tableBaseView;

@end
