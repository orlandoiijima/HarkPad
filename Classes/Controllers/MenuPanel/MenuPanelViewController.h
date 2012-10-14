//
//  MenuPanelViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "CategoryPanelView.h"
#import "ProductPanelView.h"

@class CategoryPanelView;
@class ProductPanelView;
@class MenuCard;

@interface MenuPanelViewController : UIViewController <ProductPanelDelegate>

@property(nonatomic, strong) CategoryPanelView *categoryPanelView;
@property(nonatomic, strong) ProductPanelView *productPanelView;
@property(nonatomic, strong) NSMutableArray *categories;

@property(nonatomic, strong) MenuCard *menuCard;

+ (MenuPanelViewController *)controllerWithMenuCard:(MenuCard *)menuCard;

@end
