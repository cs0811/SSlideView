//
//  SSlideView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideView.h"
#import "SSlideViewCollectionCell.h"
#import "UIScrollView+SSlideViewAddition.h"

#define kContentOffset      @"contentOffset"

typedef NS_ENUM(NSInteger, SlideViewScrollStatus) {
    SlideViewScrollStatus_Begin = 0,    // 开始滚动
    SlideViewScrollStatus_End ,         // 结束滚动
};

@interface SSlideView ()<UICollectionViewDelegate,UICollectionViewDataSource,SSlideTabBarViewDelegate>
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
@property (nonatomic, assign) BOOL tabBarHasStatic;
@property (nonatomic, assign) BOOL animationCompleted;
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

- (void)dealloc {
    [self removeItemsObserver];
}

#pragma mark loadBaseUI 
- (void)loadBaseUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}
- (void)loadData {
    self.itemsArr = [NSMutableArray array];
    self.currentScrollView = self.itemsArr.firstObject;
    self.tabBarHasStatic = NO;
    self.animationCompleted = YES;
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
    
    if ([self.delegate respondsToSelector:@selector(slideHeaderViewOfSSlideView:)]) {
        self.headerView = [self.delegate slideHeaderViewOfSSlideView:self];
    }
    if ([self.delegate respondsToSelector:@selector(slideTabBarViewOfSSlideView:)]) {
        self.tabBarView = [self.delegate slideTabBarViewOfSSlideView:self];
    }
    if ([self.delegate respondsToSelector:@selector(slideView:itemAtIndex:)]) {
        cell.tableView = (UITableView *)[self.delegate slideView:self itemAtIndex:indexPath.item];
        cell.tableView.contentInset = UIEdgeInsetsMake(self.tableInsetHeight, 0, 0, 0);
        [cell.tableView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:nil];
        [self.itemsArr replaceObjectAtIndex:indexPath.item withObject:cell.tableView];
        
        if (indexPath.item == 0) {
            // 第一个scrollview 手动加上头视图
            [self scrollViewDidEndDecelerating:self.collectionView];
        }else {
            // 保证第一次出现的item的contentOffset和上一个一样
            if (self.tabBarHasStatic) {
                [cell.tableView setContentOffset:CGPointMake(0, -CGRectGetHeight(self.tabBarView.frame)) animated:NO];
            }else {
                [cell.tableView setContentOffset:self.currentScrollView.contentOffset animated:NO];
            }
        }
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    if (_currentIndex >= self.itemsArr.count) {
        return;
    }
    self.currentScrollView = self.itemsArr[self.currentIndex];
    if (!self.tabBarHasStatic) {
        [self updateAllItemOffY:self.currentScrollView.contentOffset.y];
        [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_Begin];
    }
    self.animationCompleted = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    if (_currentIndex >= self.itemsArr.count) {
        return;
    }
    if (scrollView.isDragging || scrollView.isDecelerating) {
        // 拖拽结束才计算
        return;
    }
    self.currentScrollView = self.itemsArr[self.currentIndex];
    if (!self.tabBarHasStatic) {
        [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_End];
    }
    self.animationCompleted = YES;
    [self.tabBarView scrollToTitleAtIndex:_currentIndex];
}

#pragma mark SSlideTabBarViewDelegate
- (void)slideTabBar:(SSlideTabBarView *)slideTabBar didSelectedTitleOfIndex:(NSInteger)index {
    CGFloat width = _collectionFrame.size.width;
    [self.collectionView setContentOffset:CGPointMake(index*width, 0) animated:YES];
}

#pragma mark update
- (void)updateAllItemOffY:(CGFloat)offy {
    for (UIScrollView * tempScrollView in self.itemsArr) {
        if (!tempScrollView || ![tempScrollView isKindOfClass:[UIScrollView class]] || tempScrollView == self.currentScrollView) {
            continue;
        }
        [tempScrollView setContentOffset:CGPointMake(0, offy) animated:NO];
    }
}

- (void)UpdateHeaderAndTabBarViewForType:(SlideViewScrollStatus)type {
    
    if (self.collectionView.decelerating) {
        return;
    }
    
    if (![self.currentScrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    if (type == SlideViewScrollStatus_Begin) {
        [self addSubview:self.headerView];
        [self addSubview:self.tabBarView];

        CGFloat offY = self.tableInsetHeight+self.currentScrollView.contentOffset.y;
        
        CGRect frame = self.headerView.frame;
        self.headerView.frame = (CGRect){0, -offY, frame.size.width, frame.size.height};
        frame = self.tabBarView.frame;
        self.tabBarView.frame = (CGRect){0, CGRectGetMaxY(self.headerView.frame), frame.size.width, frame.size.height};
        
    }else if (type == SlideViewScrollStatus_End) {
        [self.currentScrollView addSubview:self.headerView];
        [self.currentScrollView addSubview:self.tabBarView];
        
        CGRect frame = self.tabBarView.frame;
        self.tabBarView.frame = (CGRect){0, -frame.size.height, frame.size.width, frame.size.height};
        frame = self.headerView.frame;
        self.headerView.frame = (CGRect){0, -self.tableInsetHeight, frame.size.width, frame.size.height};
    }    
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (![keyPath isEqual:kContentOffset]) {
        return;
    }
    
    CGPoint point = [change[@"new"] CGPointValue];
    CGFloat offY = point.y;
    
    if (offY >= -CGRectGetHeight(self.tabBarView.frame)) {
        // 悬停
        self.tabBarHasStatic = YES;
        self.currentScrollView.tabBarHasStatic = YES;
        
        if (self.tabBarView.superview == self) {
            return;
        }
        [self addSubview:self.tabBarView];
        CGRect frame = self.tabBarView.frame;
        frame.origin.y = 0;
        self.tabBarView.frame = frame;
        [self updateAllItemOffY:-CGRectGetHeight(self.tabBarView.frame)];
        
    }else {
        if (self.tabBarView.superview == self && self.animationCompleted) {
            [self scrollViewDidEndDecelerating:self.collectionView];
        }
        self.tabBarHasStatic = NO;
        self.currentScrollView.tabBarHasStatic = NO;
    }
}

// 移除监听
- (void)removeItemsObserver {
    for (UIScrollView * tempScrollView in self.itemsArr) {
        if (!tempScrollView || ![tempScrollView isKindOfClass:[UIScrollView class]] || tempScrollView == self.currentScrollView) {
            continue;
        }
        [tempScrollView removeObserver:self forKeyPath:kContentOffset];
    }
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
    self.tableInsetHeight += CGRectGetHeight(_headerView.frame);
}
- (void)setTabBarView:(SSlideTabBarView *)tabBarView {
    _tabBarView = tabBarView;
    _tabBarView.delegate = self;
    self.tableInsetHeight += CGRectGetHeight(_tabBarView.frame);
}

@end
