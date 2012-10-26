//
//  LXReorderableCollectionViewFlowLayout.h
//
//  Created by Stan Chang Khin Boon on 1/10/12.
//  Copyright (c) 2012 d--buzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXReorderableCollectionViewFlowLayout : UICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (assign, nonatomic) UIEdgeInsets triggerScrollingEdgeInsets;
@property (assign, nonatomic) CGFloat scrollingSpeed;
@property (strong, nonatomic) NSTimer *scrollingTimer;

@property (weak, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;
@property (weak, nonatomic) UIView *currentView;
@property (assign, nonatomic) CGPoint currentViewCenter;
@property (assign, nonatomic) CGPoint panTranslationInCollectionView;

@property (assign, nonatomic) BOOL alwaysScroll;

- (void)setUpGestureRecognizersOnCollectionView;

@end

@protocol LXReorderableCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath willMoveToIndexPath:(NSIndexPath *)theToIndexPath;
- (BOOL)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath canMoveToIndexPath:(NSIndexPath *)theToIndexPath;
- (void)collectionView:(UICollectionView *)view layout:(LXReorderableCollectionViewFlowLayout *)layout didDropAtIndexPath:(NSIndexPath *)path;
- (void)collectionView:(UICollectionView *)view layout:(LXReorderableCollectionViewFlowLayout *)layout didStartDragAtIndexPath:(NSIndexPath *)path;
@end