//
//  CategoryPanelView.h
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class ProductCategory;
@class MenuCardViewController;

@protocol CategoryPanelDelegate <NSObject>

@optional
- (void) didTapCategory: (ProductCategory *)category;
- (void) didLongPressCategory: (ProductCategory *)category;
@end


@interface CategoryPanelView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (retain) id<CategoryPanelDelegate> panelDelegate;

@property(nonatomic, strong) NSMutableArray *categories;

@property(nonatomic, strong) id selectedCategory;

+ (CategoryPanelView *)panelWithFrame:(CGRect)frame delegate:(id <CategoryPanelDelegate>)delegate;


@end
