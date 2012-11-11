//
//  MenuPanelView.h
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "ProductPanelView.h"
#import "CategoryPanelView.h"

@class CategoryPanelView;
@class ProductPanelView;
@class MenuCard;

@interface MenuPanelView : UIView <ProductPanelDelegate>

typedef enum MenuPanelShow {MenuPanelShowProducts, MenuPanelShowAll} MenuPanelShow;

@property(nonatomic, strong) NSMutableArray *categories;
@property(nonatomic, strong) CategoryPanelView *categoryPanelView;
@property(nonatomic, strong) ProductPanelView *productPanelView;
@property(nonatomic, strong) id<ProductPanelDelegate> delegate;

@property(nonatomic, strong) id selectedItem;

@property(nonatomic) MenuPanelShow show;

- (void)setMenuCard:(MenuCard *)card;

+ (MenuPanelView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show delegate:(id <ProductPanelDelegate>)delegate;

@end