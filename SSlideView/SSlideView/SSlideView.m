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

@interface SSlideView ()<UICollectionViewDelegate,UICollectionViewDataSource,SSlideViewCollectionCellDelegate,SSlideTabBarViewDelegate>
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
@property (nonatomic, assign) BOOL tabBarHasStatic;
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

#pragma mark - loadBaseUI
- (void)loadBaseUI {
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}

- (void)loadData {
    self.tabBarHasStatic = NO;
    self.refreshPosition = SSlideViewRefreshPosition_HeaderViewTop;
    self.scrollEnable = YES;
    self.bouncesEnable = YES;
    self.contentOffSetOverBordered = NO;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInSSlideView:)]) {
        NSInteger count = [self.delegate numberOfItemsInSSlideView:self];
        self.itemsArr = [NSMutableArray arrayWithCapacity:count];
        self.contentOffSetArr = [NSMutableArray arrayWithCapacity:count];
        
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
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SSlideViewCollectionCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self willShowCell:cell indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)willShowCell:(SSlideViewCollectionCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    cell.delegate = self;
    self.tableInsetHeight = 0;
    
    if ([self.delegate respondsToSelector:@selector(slideHeaderViewOfSSlideView:)]) {
        self.headerView = [self.delegate slideHeaderViewOfSSlideView:self];
    }
    if ([self.delegate respondsToSelector:@selector(slideTabBarViewOfSSlideView:)]) {
        self.tabBarView = [self.delegate slideTabBarViewOfSSlideView:self];
    }
    if ([self.delegate respondsToSelector:@selector(slideView:itemSuperViewAtIndex:)]) {
        cell.scrollBaseView = [self.delegate slideView:self itemSuperViewAtIndex:indexPath.item];
    }
    if ([self.delegate respondsToSelector:@selector(slideView:itemAtIndex:)]) {
        cell.scrollView = [self.delegate slideView:self itemAtIndex:indexPath.item];
        cell.scrollView.contentInset = UIEdgeInsetsMake(self.tableInsetHeight, 0, 0, 0);
        [cell.scrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:nil];
        if (self.refreshPosition == SSlideViewRefreshPosition_HeaderViewTop) {
            cell.scrollView.mj_header.ignoredScrollViewContentInsetTop = self.tableInsetHeight;
        }else {
            cell.scrollView.mj_header.ignoredScrollViewContentInsetTop = 0;
        }
        
        [self.itemsArr replaceObjectAtIndex:indexPath.item withObject:cell.scrollView];
        
        [self updateScrollViewContentOffSetWithCell:cell indexPath:indexPath];
        if (!self.currentScrollView) {
            self.currentScrollView = cell.scrollView;
            [self updateHeaderAndTabBarViewForType:SlideViewScrollStatus_End];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.currentIndex = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    if (self.currentIndex >= self.itemsArr.count) {
        return;
    }
    
    [self handleScrollViewWillBeginDragging];
}

- (void)handleScrollViewWillBeginDragging {
    
    if (!self.tabBarHasStatic) {
        if (!self.contentOffSetOverBordered) {
            [self updateHeaderAndTabBarViewForType:SlideViewScrollStatus_Begin];
        }
    }
    
    // 记录当前的offset
    CGFloat offset = self.currentScrollView.contentOffset.y;
    if (offset < -self.tableInsetHeight) {
        offset = -self.tableInsetHeight;
    }
    [self.contentOffSetArr replaceObjectAtIndex:self.currentIndex withObject:@(offset)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger tempIndex = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    if ( [self.delegate respondsToSelector:@selector(slideView:didScrollToIndex:)]) {
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
    
    [self handleScrollViewDidEndDecelerating];
    
    [self.tabBarView scrollToTitleAtIndex:_currentIndex];
}

- (void)handleScrollViewDidEndDecelerating {
    
    self.currentScrollView = self.itemsArr[_currentIndex];
    
    if (!self.tabBarHasStatic) {
        [self updateHeaderAndTabBarViewForType:SlideViewScrollStatus_End];
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
            [self updateHeaderAndTabBarViewForType:SlideViewScrollStatus_Begin];
        }
    }
}

#pragma mark - SSlideViewCollectionCellDelegate
- (void)removeCurrentScrollViewObserver:(UIScrollView *)scrollView {
    [scrollView removeObserver:self forKeyPath:kContentOffset];
}

#pragma mark - SSlideTabBarViewDelegate
- (void)slideTabBar:(SSlideTabBarView *)slideTabBar didSelectedTitleOfIndex:(NSInteger)index {
    if (index == _currentIndex) {
        return;
    }
    self.userInteractionEnabled = NO;
    
    // 模拟开始拖到
    [self handleScrollViewWillBeginDragging];
    
    [self.collectionView setContentOffset:CGPointMake(index * CGRectGetWidth(self.collectionView.frame), 0)];
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    
    // 模拟 cellWillDisney
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    SSlideViewCollectionCell *cell = (SSlideViewCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    }
    [self willShowCell:cell indexPath:indexPath];
    
    _currentIndex = index;
    // 模拟结束滚动
    [self handleScrollViewDidEndDecelerating];
    
    self.userInteractionEnabled = YES;
}

#pragma mark - update
- (void)updateHeaderAndTabBarViewForType:(SlideViewScrollStatus)type {
    [self updateHeaderAndTabBarViewForType:type scrollView:nil];
}

- (void)updateHeaderAndTabBarViewForType:(SlideViewScrollStatus)type scrollView:(UIScrollView *)scrollView {
    
    if (self.collectionView.decelerating) {
        return;
    }
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(CGRectGetWidth(_collectionFrame), self.tableInsetHeight);
    if (type == SlideViewScrollStatus_Begin) {
        [self addSubview:self.baseHeaderView];
        
        CGFloat offY = self.tableInsetHeight+self.currentScrollView.contentOffset.y;
        frame.origin.y = -offY;
        self.baseHeaderView.frame = frame;
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
    }else if (type == SlideViewScrollStatus_End) {
        if (scrollView) {
            [scrollView addSubview:self.baseHeaderView];
        }else {
            [self.currentScrollView addSubview:self.baseHeaderView];
        }
        
        frame.origin.y = -self.tableInsetHeight;
        self.baseHeaderView.frame = frame;
        
        [scrollView setNeedsLayout];
        [scrollView layoutIfNeeded];
        [self.currentScrollView setNeedsLayout];
        [self.currentScrollView layoutIfNeeded];
        
    }else if (type == SlideViewScrollStatus_StaticTabBar) {
        [self addSubview:self.baseHeaderView];
        
        frame.origin.y = -CGRectGetHeight(self.headerView.frame)+self.tabBarOffSetYToTop;
        self.baseHeaderView.frame = frame;
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
    }else if (type == SlideViewScrollStatus_StaticHeaderViewAndTabBar) {
        [self addSubview:self.baseHeaderView];
        
        frame.origin.y = 0;
        self.baseHeaderView.frame = frame;
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)updateAllOffset {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (NSObject *obj in self.contentOffSetArr) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *offset = (NSNumber *)obj;
            offset = @(self.currentScrollView.contentOffset.y);
            [arr addObject:offset];
        }else {
            [arr addObject:obj];
        }
    }
    
    self.contentOffSetArr = arr;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (![keyPath isEqual:kContentOffset]) {
        return;
    }
    
    if (self.collectionView.isDragging) {
        return;
    }
    
    // 只处理被添加的scrollviewItem的滚动
    
    CGPoint point = [change[@"new"] CGPointValue];
    CGFloat offY = point.y;
    
    if (offY >= -self.tabStaticHeight-self.tabBarOffSetYToTop) {
        // 悬停
        if (self.baseHeaderView.superview == self) {
            return;
        }
        self.tabBarHasStatic = YES;
        
        if (self.currentScrollView.contentOffset.y >= -self.tabStaticHeight-self.tabBarOffSetYToTop) {
            [self updateHeaderAndTabBarViewForType:SlideViewScrollStatus_StaticTabBar];
        }
        
    }else {
        
        if (offY<-self.tableInsetHeight && self.refreshPosition == SSlideViewRefreshPosition_TabBarBottom) {
            // 控制刷新位置
            if (self.baseHeaderView.superview != self) {
                self.tabBarHasStatic = NO;
                
                [self updateHeaderAndTabBarViewForType:SlideViewScrollStatus_StaticHeaderViewAndTabBar];
            }
        }else {
            if (offY < -self.tabStaticHeight-self.tabBarOffSetYToTop) {
                
                if (self.baseHeaderView.superview == self || !self.baseHeaderView.superview) {
                    self.tabBarHasStatic = NO;
                    
                    [self updateHeaderAndTabBarViewForType:SlideViewScrollStatus_End];
                }
            }
        }
    }
}

#pragma mark - Action
- (void)updateScrollViewContentOffSetWithCell:(SSlideViewCollectionCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    CGFloat offset = self.currentScrollView.contentOffset.y;
    if (!self.currentScrollView) {
        offset = -self.tableInsetHeight;
        [cell.scrollView setContentOffset:CGPointMake(0, offset) animated:NO];
        return;
    }
    
    if (self.tabBarHasStatic) {
        NSNumber * itemOffY = self.contentOffSetArr[indexPath.item];
        [self setScrollView:cell.scrollView staticContentSetOffYWithNumber:itemOffY];
    }else {
        CGPoint offset = self.currentScrollView.contentOffset;
        if (offset.y < -self.tableInsetHeight) {
            // 防止上一个scrollview 还在滚动
            offset.y = - self.tableInsetHeight;
        }
        [cell.scrollView setContentOffset:offset animated:NO];
        // 更新所有的offset
        [self updateAllOffset];
    }
}

// 移除监听
- (void)removeItemsObserver {
    [self handleSlideCellFromView:self.collectionView completion:^(SSlideViewCollectionCell *cell) {
        [cell.scrollView removeObserver:self forKeyPath:kContentOffset];
    }];
}

- (void)handleSlideCellFromView:(UIView *)topView completion:(void(^)(SSlideViewCollectionCell *))completion {
    
    for (UIView *view in topView.subviews) {
        if (![view isKindOfClass:[SSlideViewCollectionCell class]]) {
            [self handleSlideCellFromView:view completion:completion];
        }else {
            completion((SSlideViewCollectionCell *)view);
        }
    }
}

- (void)setScrollView:(UIScrollView *)scrollView staticContentSetOffYWithNumber:(NSNumber *)itemOffY {
    
    if ([itemOffY isKindOfClass:[NSNumber class]] && itemOffY.floatValue >= -self.tabStaticHeight-self.tabBarOffSetYToTop) {
        // 恢复之前的 contentOffSet
        [scrollView setContentOffset:CGPointMake(0, itemOffY.floatValue) animated:NO];
    }else {
        [scrollView setContentOffset:CGPointMake(0, -self.tabStaticHeight-self.tabBarOffSetYToTop) animated:NO];
    }
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)scrollToTop {
    [self.currentScrollView setContentOffset:CGPointMake(0, -self.tableInsetHeight) animated:YES];
}

#pragma mark - Getter
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
