//
//  SSlideView.m
//  SSlideView
//
//  Created by tongxuan on 16/11/23.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "SSlideView.h"
#import "SSlideViewCollectionCell.h"


#define kContentOffset      @"contentOffset"


typedef NS_ENUM(NSInteger, SlideViewScrollStatus) {
    SlideViewScrollStatus_Begin = 0,    // 开始滚动 (水平)
    SlideViewScrollStatus_End ,         // 结束滚动 (水平)
    SlideViewScrollStatus_StaticTabBar ,    // 悬停TabBar
    SlideViewScrollStatus_StaticHeaderViewAndTabBar ,       // 悬停TabBar与HeaderView
};

@interface SSlideView ()<UICollectionViewDelegate,UICollectionViewDataSource,SSlideTabBarViewDelegate>
{
    CGRect _collectionFrame;
}
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIView * baseHeaderView;
@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) SSlideTabBarView * tabBarView;

@property (nonatomic, strong) UIScrollView * currentScrollView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray * itemsArr;
@property (nonatomic, strong) NSMutableArray * contentOffSetArr;

@property (nonatomic, assign) CGFloat tableInsetHeight;
@property (nonatomic, assign) BOOL loadFirst;
@property (nonatomic, assign) BOOL tabBarHasStatic;
@property (nonatomic, assign) BOOL animationCompleted;
@property (nonatomic, assign) BOOL isScrollFromTabBarView;
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
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}
- (void)loadData {
    self.itemsArr = [NSMutableArray array];
    self.contentOffSetArr = [NSMutableArray array];
    self.currentScrollView = self.itemsArr.firstObject;
    self.tabBarHasStatic = NO;
    self.animationCompleted = YES;
    self.loadFirst = YES;
    self.refreshAtTabBarViewTop = YES;
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
            [self.contentOffSetArr addObject:@""];
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
    if ([self.delegate respondsToSelector:@selector(slideView:itemViewAtIndex:)]) {
        cell.tableBaseView = [self.delegate slideView:self itemViewAtIndex:indexPath.item];
    }
    if ([self.delegate respondsToSelector:@selector(slideView:itemAtIndex:)]) {
        cell.tableView = (UITableView *)[self.delegate slideView:self itemAtIndex:indexPath.item];
        cell.tableView.contentInset = UIEdgeInsetsMake(self.tableInsetHeight, 0, 0, 0);
        [cell.tableView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:nil];
        if (self.refreshAtTabBarViewTop) {
            cell.tableView.mj_header.ignoredScrollViewContentInsetTop = self.tableInsetHeight;
        }else {
            cell.tableView.mj_header.ignoredScrollViewContentInsetTop = 0;
        }
        [self.itemsArr replaceObjectAtIndex:indexPath.item withObject:cell.tableView];
        
        if (indexPath.item == 0) {
            // 第一个scrollview 手动加上头视图
            if (self.loadFirst) {
                [self scrollViewDidEndDecelerating:self.collectionView];
                self.loadFirst = NO;
            }
        }else {
            // 保证第一次出现的item的contentOffset和上一个一样
            if (self.tabBarHasStatic) {
                NSNumber * itemOffY = self.contentOffSetArr[indexPath.item];
                if ([itemOffY isKindOfClass:[NSNumber class]]) {
                    // 恢复之前的 contentOffSet
                    [cell.tableView setContentOffset:CGPointMake(0, itemOffY.floatValue) animated:NO];
                }else {
                    [cell.tableView setContentOffset:CGPointMake(0, -CGRectGetHeight(self.tabBarView.frame)) animated:NO];
                }
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
    // 记录 contentOffSet
    [self.contentOffSetArr replaceObjectAtIndex:_currentIndex withObject:@(self.currentScrollView.contentOffset.y)];
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

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.isScrollFromTabBarView) {
        [self scrollViewDidEndDecelerating:self.collectionView];
        self.isScrollFromTabBarView = NO;
    }
}

#pragma mark SSlideTabBarViewDelegate
- (void)slideTabBar:(SSlideTabBarView *)slideTabBar didSelectedTitleOfIndex:(NSInteger)index {
    if (index == _currentIndex) {
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self scrollViewWillBeginDragging:self.collectionView];
    self.isScrollFromTabBarView = YES;
}

#pragma mark update
- (void)updateAllItemOffY:(CGFloat)offy {
    for (UIScrollView * tempScrollView in self.itemsArr) {
        if (!tempScrollView || ![tempScrollView isKindOfClass:[UIScrollView class]] || tempScrollView == self.currentScrollView) {
            continue;
        }
        if (self.tabBarHasStatic && tempScrollView.contentOffset.y > -CGRectGetHeight(self.tabBarView.frame)) {
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
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(CGRectGetWidth(_collectionFrame), self.tableInsetHeight);
    if (type == SlideViewScrollStatus_Begin) {
        [self addSubview:self.baseHeaderView];

        CGFloat offY = self.tableInsetHeight+self.currentScrollView.contentOffset.y;
        frame.origin.y = -offY;
        self.baseHeaderView.frame = frame;
        
    }else if (type == SlideViewScrollStatus_End) {
        [self.currentScrollView addSubview:self.baseHeaderView];
        
        frame.origin.y = -self.tableInsetHeight;
        self.baseHeaderView.frame = frame;

    }else if (type == SlideViewScrollStatus_StaticTabBar) {
        [self addSubview:self.baseHeaderView];

        frame.origin.y = -CGRectGetHeight(self.headerView.frame);
        self.baseHeaderView.frame = frame;

    }else if (type == SlideViewScrollStatus_StaticHeaderViewAndTabBar) {
        [self addSubview:self.baseHeaderView];
        
        frame.origin.y = 0;
        self.baseHeaderView.frame = frame;
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
        
        if (self.baseHeaderView.superview == self) {
            return;
        }
        [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_StaticTabBar];
        [self updateAllItemOffY:-CGRectGetHeight(self.tabBarView.frame)];
        
    }else {
                
        if (offY<=-self.tableInsetHeight && !self.refreshAtTabBarViewTop) {
            self.tabBarHasStatic = YES;

            if (self.baseHeaderView.superview != self && self.animationCompleted && !self.isScrollFromTabBarView) {
                [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_StaticHeaderViewAndTabBar];
            }
        }else {
            self.tabBarHasStatic = NO;
            if (self.baseHeaderView.superview == self && self.animationCompleted && !self.isScrollFromTabBarView) {
                [self scrollViewDidEndDecelerating:self.collectionView];
            }
        }
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
- (UIView *)baseHeaderView {
    if (!_baseHeaderView) {
        UIView * view = [UIView new];
        view.userInteractionEnabled = YES;
        _baseHeaderView = view;
    }
    return _baseHeaderView;
}

- (void)setHeaderView:(UIView *)headerView {
    _headerView = headerView;
    _headerView.frame = CGRectMake(0, 0, CGRectGetWidth(headerView.frame), CGRectGetHeight(headerView.frame));
    [self.baseHeaderView addSubview:_headerView];
    self.tableInsetHeight += CGRectGetHeight(_headerView.frame);
}
- (void)setTabBarView:(SSlideTabBarView *)tabBarView {
    _tabBarView = tabBarView;
    _tabBarView.delegate = self;
    _tabBarView.frame = CGRectMake(0, self.tableInsetHeight, CGRectGetWidth(tabBarView.frame), CGRectGetHeight(tabBarView.frame));
    [self.baseHeaderView addSubview:_tabBarView];
    self.tableInsetHeight += CGRectGetHeight(_tabBarView.frame);
}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if (CGRectContainsPoint(self.headerView.frame, point)) {
//        return  nil;
//    }
//    if (CGRectContainsPoint(self.tabBarView.frame, point)) {
//        return  nil;
//    }
//    return [super hitTest:point withEvent:event];
//}

@end