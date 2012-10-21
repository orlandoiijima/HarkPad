//
//  MenuCollectionViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "MenuPanelView.h"
#import "MenuDelegate.h"
@class MenuCard;

@interface MenuCollectionViewController : UIViewController

@property(nonatomic, strong) MenuCard *menuCard;
@property(nonatomic) enum MenuPanelShow show;
@property(nonatomic, strong) id <MenuDelegate> delegate;

@property(nonatomic, strong) id selectedItem;

+ (MenuCollectionViewController *)controllerWithMenuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show delegate:(id <ProductPanelDelegate>)delegate;

@end
