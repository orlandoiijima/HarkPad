//
//  CategoryPanelView.h
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class ProductCategory;
@class MenuCardViewController;
@protocol ProductPanelDelegate;

@interface CategoryPanelView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (retain) id<ProductPanelDelegate> panelDelegate;

@property(nonatomic, strong) NSMutableArray *categories;

@property(nonatomic, strong) id selectedCategory;

+ (CategoryPanelView *)panelWithFrame:(CGRect)frame delegate:(id <ProductPanelDelegate>)delegate;


- (void)refreshCategory:(ProductCategory *)category;
@end
