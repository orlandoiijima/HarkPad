//
//  MenuCollectionView.h
//  HarkPad
//
//  Created by Willem Bison on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "MenuPanelView.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@protocol MenuDelegate;
@class MenuCard;
@class ProductCategory;
@class Product;

@interface MenuCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate,LXReorderableCollectionViewDelegateFlowLayout>

@property(nonatomic) enum MenuPanelShow show;
@property(nonatomic, strong) NSMutableArray *categories;
@property(nonatomic) BOOL isEditing;

@property(nonatomic, strong) id selectedItem;

@property(nonatomic, strong) id <MenuDelegate> menuDelegate;

@property(nonatomic, strong) MenuCard *menuCard;

@property(nonatomic, strong) ProductCategory *draggingFromCategory;

@property(nonatomic, strong) NSIndexPath *draggingFromIndexPath;

@property(nonatomic, strong) Product * draggingProduct;

@property(nonatomic) int numberOfColumns;

+ (MenuCollectionView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show numberOfColumns:(int)numberOfColumns editing:(BOOL)editing menuDelegate:(id <MenuDelegate>)menuDelegate;

- (ProductCategory *)categoryBySection:(int)section;

- (int)sectionByCategory:(ProductCategory *)category;

- (id)itemAtIndexPath:(NSIndexPath *)path;

- (NSMutableArray *)indexPathsForItem:(id)item;

- (void)collectionView:(UICollectionView *)view layout:(LXReorderableCollectionViewFlowLayout *)layout didStartDragAtIndexPath:(NSIndexPath *)path;

- (void)refreshItem:(id)item;
- (void)deleteItem:(id)item;

- (void)addToFavorites:(id)item;

- (void)removeFromFavorites:(id)item;

- (void)insertCategory:(ProductCategory *)category atIndex:(NSInteger)index;

- (int)sectionFromPoint:(CGPoint)point;

@end
