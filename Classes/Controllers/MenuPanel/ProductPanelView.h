//
//  ProductPanelView.h
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class Product;
@class ProductCategory;
@class MenuCard;
@protocol ProductPanelDelegate <NSObject>

@optional
- (void) didTapProduct: (Product *)product;
- (void) didTapDummy;
- (void) didSelectProduct: (Product *)product;
- (BOOL) canDeselect;
- (void) didTapCategory: (ProductCategory *)category;
//- (void) didInclude: (id)item inQuickMenu: (bool)include;
- (void) didLongPressProduct: (Product *)product;
- (void) didLongPressCategory: (ProductCategory *)category;
@end

@interface ProductPanelView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (retain) id<ProductPanelDelegate> panelDelegate;
@property(nonatomic, strong) Product *selectedItem;
@property(nonatomic, strong) MenuCard *menuCard;
@property(nonatomic, strong) ProductCategory *category;

+ (ProductPanelView *)panelWithFrame:(CGRect)frame delegate:(id <ProductPanelDelegate>)delegate;

@end
