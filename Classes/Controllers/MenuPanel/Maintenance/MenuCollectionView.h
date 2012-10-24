//
//  MenuCollectionView.h
//  HarkPad
//
//  Created by Willem Bison on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "MenuPanelView.h"

@protocol MenuDelegate;
@class MenuCard;

@interface MenuCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic) enum MenuPanelShow show;
@property(nonatomic, strong) NSMutableArray *categories;
@property(nonatomic) BOOL isEditing;

@property(nonatomic, strong) id selectedItem;

@property(nonatomic, strong) id <MenuDelegate> menuDelegate;

@property(nonatomic, strong) MenuCard *menuCard;

+ (MenuCollectionView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show editing:(BOOL)editing delegate:(id <MenuDelegate>)delegate;

- (int)sectionByCategory:(ProductCategory *)category;

- (id)itemAtIndexPath:(NSIndexPath *)path;

- (NSIndexPath *)indexPathForItem:(id)item;

- (void)refreshItem:(id)item;
- (void)deleteItem:(id)item;

- (void)addToFavorites:(id)item;

- (void)removeFromFavorites:(id)item;


@end
