//
//  MenuCard.h
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "ProductPanelView.h"

@class ProductPropertiesView;
@class MenuPanelView;
@class MenuCard;

@interface MenuCardViewController : UIViewController <ProductPanelDelegate>

@property(nonatomic, strong) IBOutlet MenuPanelView *menuPanel;
@property(nonatomic, strong) IBOutlet ProductPropertiesView * productProperties;

@property(nonatomic, strong) MenuCard *menuCard;

+ (MenuCardViewController *)controllerWithMenuCard:(MenuCard *)card;

@end
