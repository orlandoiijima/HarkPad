//
//  ProductPanelView.h
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class Product;
@class Menu;
@class ProductCategory;

@protocol ProductPanelDelegate <NSObject>

@optional
- (void) didTapProduct: (Product *)product;
- (BOOL) canDeselect;
- (void) didTapCategory: (ProductCategory *)category;
- (void) didTapMenu: (Menu *)menu;
- (void) didLongPressProduct: (Product *)product;
- (void) didLongPressMenu: (Menu *)menu;
- (void) didLongPressCategory: (ProductCategory *)category;
@end

@interface ProductPanelView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (retain) id<ProductPanelDelegate> panelDelegate;

@property(nonatomic, strong) NSMutableArray * products;


@property(nonatomic, strong) Product *selectedItem;

+ (ProductPanelView *)panelWithFrame:(CGRect)frame delegate:(id <ProductPanelDelegate>)delegate;

- (void)refreshProduct:(Product *)product;

@end
