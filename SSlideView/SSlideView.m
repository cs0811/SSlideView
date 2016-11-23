//
//  SSlideView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideView.h"
#import "SSlideViewCollectionCell.h"

typedef NS_ENUM(NSInteger, SlideViewScrollStatus) {
    SlideViewScrollStatus_Begin = 0,    // 开始滚动
    SlideViewScrollStatus_End ,         // 结束滚动
};

@interface SSlideView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    CGRect _collectionFrame;
}
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) SSlideTabBarView * tabBarView;
@property (nonatomic, strong) UIScrollView * currentScrollView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray * itemsArr;

@property (nonatomic, assign) CGFloat tableInsetHeight;
@end

@implementation SSlideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _collectionFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self loadBaseUI];
        [self loadData];
    }
    return self;
}

#pragma mark loadBaseUI 
- (void)loadBaseUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}
- (void)loadData {
    self.itemsArr = [NSMutableArray array];
}

#pragma mark UICollectionViewDataSource 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInSSlideView:)]) {
        NSInteger count = [self.delegate numberOfItemsInSSlideView:self];
        self.itemsArr = [NSMutableArray arrayWithCapacity:count];
        for (int i=0; i<count; i++) {
            [self.itemsArr addObject:@""];
        }
        return count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSlideViewCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSSlideViewCollectionCell forIndexPath:indexPath];
    
    self.tableInsetHeight = 0;
    
    if ([self.delegate respondsToSelector:@selector(slideTabBarViewOfSSlideView:)]) {
        self.tabBarView = [self.delegate slideTabBarViewOfSSlideView:self];
    }
    if ([self.delegate respondsToSelector:@selector(headerViewOfSSlideView:)]) {
        self.headerView = [self.delegate headerViewOfSSlideView:self];
    }
    if ([self.delegate respondsToSelector:@selector(slideView:itemAtIndex:)]) {
        cell.tableView = (UITableView *)[self.delegate slideView:self itemAtIndex:indexPath.item];
        cell.tableView.contentInset = UIEdgeInsetsMake(self.tableInsetHeight, 0, 0, 0);
        [self.itemsArr replaceObjectAtIndex:indexPath.item withObject:cell.tableView];
        
        if (indexPath.item == 0) {
            // 第一个scrollview 手动加上头视图
            [self scrollViewDidEndDecelerating:self.collectionView];
        }
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    if (_currentIndex >= self.itemsArr.count) {
        return;
    }
    [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_Begin];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    if (_currentIndex >= self.itemsArr.count) {
        return;
    }
    [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_End];
}

#pragma mark
- (void)UpdateHeaderAndTabBarViewForType:(SlideViewScrollStatus)type {
    
    self.currentScrollView = self.itemsArr[self.currentIndex];
    if (![self.currentScrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    if (type == SlideViewScrollStatus_Begin) {
        [self addSubview:self.headerView];
        [self addSubview:self.tabBarView];
        [self bringSubviewToFront:self.headerView];
        [self bringSubviewToFront:self.tabBarView];
    }else if (type == SlideViewScrollStatus_End) {
        [self.currentScrollView addSubview:self.headerView];
        [self.currentScrollView addSubview:self.tabBarView];
    }
    CGRect frame = self.tabBarView.frame;
    self.tabBarView.frame = (CGRect){0, -frame.size.height, frame.size.width, frame.size.height};
    frame = self.headerView.frame;
    self.headerView.frame = (CGRect){0, -self.tableInsetHeight, frame.size.width, frame.size.height};
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
- (void)setHeaderView:(UIView *)headerView {
    _headerView = headerView;
    _headerView.frame = headerView.bounds;
    self.tableInsetHeight += CGRectGetHeight(_headerView.frame);
}
- (void)setTabBarView:(SSlideTabBarView *)tabBarView {
    _tabBarView = tabBarView;
    _tabBarView.frame = tabBarView.bounds;
    self.tableInsetHeight += CGRectGetHeight(_tabBarView.frame);
}

@end
