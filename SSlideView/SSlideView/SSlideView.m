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
@property (nonatomic, assign) CGFloat tabStaticHeight;
@property (nonatomic, assign) BOOL loadFirst;
@property (nonatomic, assign) BOOL tabBarHasStatic;
@property (nonatomic, assign) BOOL animationCompleted;
@property (nonatomic, assign) BOOL isScrollFromTabBarView;
@property (nonatomic, assign) BOOL contentOffSetOverBordered;
@end

@implementation SSlideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _collectionFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self loadData];
        [self loadBaseUI];
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
    self.refreshPosition = SSlideViewRefreshPosition_HeaderViewTop;
    self.scrollEnable = YES;
    self.bouncesEnable = YES;
    self.contentOffSetOverBordered = NO;
}

#pragma mark UICollectionViewDataSource 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfItemsInSSlideView:)]) {
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideHeaderViewOfSSlideView:)]) {
        self.headerView = [self.delegate slideHeaderViewOfSSlideView:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideTabBarViewOfSSlideView:)]) {
        self.tabBarView = [self.delegate slideTabBarViewOfSSlideView:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideView:itemSuperViewAtIndex:)]) {
        cell.tableBaseView = [self.delegate slideView:self itemSuperViewAtIndex:indexPath.item];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideView:itemAtIndex:)]) {
        cell.tableView = (UITableView *)[self.delegate slideView:self itemAtIndex:indexPath.item];
        cell.tableView.contentInset = UIEdgeInsetsMake(self.tableInsetHeight, 0, 0, 0);
        [cell.tableView setContentOffset:CGPointMake(0, -self.tableInsetHeight) animated:NO];
        [cell.tableView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:nil];
        if (self.refreshPosition == SSlideViewRefreshPosition_HeaderViewTop) {
            cell.tableView.mj_header.ignoredScrollViewContentInsetTop = self.tableInsetHeight;
        }else {
            cell.tableView.mj_header.ignoredScrollViewContentInsetTop = 0;
        }
        [self.itemsArr replaceObjectAtIndex:indexPath.item withObject:cell.tableView];
        
        if (indexPath.item == 0) {
            if (self.loadFirst) {
                // 第一个scrollview 手动加上头视图
                [self scrollViewDidEndDecelerating:self.collectionView];
                self.loadFirst = NO;
            }else {
                [self handleCellForRow:cell indexPath:indexPath];
            }
        }else {
            [self handleCellForRow:cell indexPath:indexPath];
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
        if (self.baseHeaderView.superview != self && !self.contentOffSetOverBordered) {
            [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_Begin];
        }
    }else {
        [self updateStaticItemOffY];
    }
    self.animationCompleted = NO;
    // 记录 contentOffSet
    [self.contentOffSetArr replaceObjectAtIndex:_currentIndex withObject:@(self.currentScrollView.contentOffset.y)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    NSInteger tempIndex = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideView:didScrollToIndex:)]) {
        if (tempIndex != _currentIndex) {
            [self.delegate slideView:self didScrollToIndex:tempIndex];
        }
    }
    _currentIndex = tempIndex;
    if (_currentIndex >= self.itemsArr.count) {
        return;
    }
    if (scrollView.isDragging || scrollView.isDecelerating) {
        // 拖拽结束才计算
        return;
    }
    self.currentScrollView = self.itemsArr[self.currentIndex];
    if (!self.tabBarHasStatic) {
        if (!self.baseHeaderView.superview || self.baseHeaderView.superview == self) {
            [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_End];
        }
    }else {
        
        NSNumber * itemOffY = self.contentOffSetArr[_currentIndex];
        [self setScrollView:self.currentScrollView staticContentSetOffYWithNumber:itemOffY];
    }
    self.animationCompleted = YES;
    // 记录 contentOffSet
    [self.contentOffSetArr replaceObjectAtIndex:_currentIndex withObject:@(self.currentScrollView.contentOffset.y)];
    [self.tabBarView scrollToTitleAtIndex:_currentIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.isScrollFromTabBarView) {
        [self scrollViewDidEndDecelerating:self.collectionView];
        self.isScrollFromTabBarView = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    // 处理快速滚动问题
    CGFloat tempOffy = scrollView.contentOffset.x/scrollView.frame.size.width;
    if (tempOffy>self.itemsArr.count-1 || tempOffy<0) {
        self.contentOffSetOverBordered = YES;
        return;
    }
    
    self.contentOffSetOverBordered = NO;
    // 判断是否为整数
    if (tempOffy != ceilf(tempOffy)) {
        if (self.baseHeaderView.superview != self) {
            [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_Begin];
        }
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
        [tempScrollView setContentOffset:CGPointMake(0, offy) animated:NO];
    }
}

- (void)updateStaticItemOffY {
    for (int i=0; i<self.itemsArr.count; i++) {
        UIScrollView * tempScrollView = self.itemsArr[i];
        if (!tempScrollView || ![tempScrollView isKindOfClass:[UIScrollView class]] || tempScrollView == self.currentScrollView) {
            continue;
        }
        
        NSNumber * itemOffY = self.contentOffSetArr[i];
        [self setScrollView:tempScrollView staticContentSetOffYWithNumber:itemOffY];
    }
}

- (void)UpdateHeaderAndTabBarViewForType:(SlideViewScrollStatus)type {
    [self UpdateHeaderAndTabBarViewForType:type scrollView:nil];
}

- (void)UpdateHeaderAndTabBarViewForType:(SlideViewScrollStatus)type scrollView:(UIScrollView *)scrollView {
    
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
        if (scrollView) {
            [scrollView addSubview:self.baseHeaderView];
        }else {
            [self.currentScrollView addSubview:self.baseHeaderView];
        }
        
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
    
    if (offY >= -self.tabStaticHeight) {
        // 悬停
        if (self.baseHeaderView.superview == self) {
            return;
        }
        self.tabBarHasStatic = YES;
        
        if (self.currentScrollView.contentOffset.y >= -self.tabStaticHeight) {
            [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_StaticTabBar];
        }
        
    }else {
                
        if (offY<=-self.tableInsetHeight && self.refreshPosition == SSlideViewRefreshPosition_TabBarBottom) {

            if (self.baseHeaderView.superview != self && self.animationCompleted && !self.isScrollFromTabBarView) {
                self.tabBarHasStatic = NO;

                [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_StaticHeaderViewAndTabBar];
            }
        }else {
            if (self.currentScrollView.contentOffset.y < -self.tabStaticHeight) {
                
                if (self.baseHeaderView.superview == self && self.animationCompleted && !self.isScrollFromTabBarView) {
                    self.tabBarHasStatic = NO;
                    
                    [self UpdateHeaderAndTabBarViewForType:SlideViewScrollStatus_End];
                }
            }
        }
    }
}

- (void)handleCellForRow:(SSlideViewCollectionCell *)cell indexPath:(NSIndexPath *)indexPath {
    // 保证第一次出现的item的contentOffset和上一个一样
    if (self.tabBarHasStatic) {
        NSNumber * itemOffY = self.contentOffSetArr[indexPath.item];
        [self setScrollView:cell.tableView staticContentSetOffYWithNumber:itemOffY];
    }else {
        [cell.tableView setContentOffset:self.currentScrollView.contentOffset animated:NO];
    }
}

// 移除监听
- (void)removeItemsObserver {
    for (UIScrollView * tempScrollView in self.itemsArr) {
        if (!tempScrollView || ![tempScrollView isKindOfClass:[UIScrollView class]]) {
            continue;
        }
        [tempScrollView removeObserver:self forKeyPath:kContentOffset];
    }
}

- (void)setScrollView:(UIScrollView *)scrollView staticContentSetOffYWithNumber:(NSNumber *)itemOffY {
    if (scrollView.contentOffset.y < -self.tabStaticHeight) {
        if ([itemOffY isKindOfClass:[NSNumber class]] && itemOffY.floatValue >= -self.tabStaticHeight) {
            // 恢复之前的 contentOffSet
            [scrollView setContentOffset:CGPointMake(0, itemOffY.floatValue) animated:NO];
        }else {
            [scrollView setContentOffset:CGPointMake(0, -self.tabStaticHeight) animated:NO];
        }
    }
}

- (void)reloadData {
    [self.collectionView reloadData];
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

- (void)setScrollEnable:(BOOL)scrollEnable {
    _scrollEnable = scrollEnable;
    self.collectionView.scrollEnabled = _scrollEnable;
}
- (void)setBouncesEnable:(BOOL)bouncesEnable {
    _bouncesEnable = bouncesEnable;
    self.collectionView.bounces = _bouncesEnable;
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
    self.tabStaticHeight = CGRectGetHeight(_tabBarView.frame);
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
