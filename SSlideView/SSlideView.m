//
//  SSlideView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideView.h"
#import "SSlideViewCollectionCell.h"

@interface SSlideView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    CGRect _collectionFrame;
}
@property (nonatomic, strong) UICollectionView * collectionView;
@end

@implementation SSlideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _collectionFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self loadBaseUI];
    }
    return self;
}

#pragma mark loadBaseUI 
- (void)loadBaseUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}

#pragma mark UICollectionViewDataSource 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInSSlideView:)]) {
        return [self.delegate numberOfItemsInSSlideView:self];
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSlideViewCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSSlideViewCollectionCell forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(slideView:itemAtIndex:)]) {
        cell.tableView = (UITableView *)[self.delegate slideView:self itemAtIndex:indexPath.item];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = _collectionFrame.size;
        
        UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:_collectionFrame collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.pagingEnabled = YES;
        [collectionView registerClass:[SSlideViewCollectionCell class] forCellWithReuseIdentifier:kSSlideViewCollectionCell];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

@end
