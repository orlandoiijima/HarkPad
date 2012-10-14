//
//  MenuCard.h
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "ProductPanelView.h"
#import "CKCalendarView.h"

@class ProductPropertiesView;
@class MenuPanelView;
@class MenuCard;

@interface MenuCardViewController : UIViewController <ProductPanelDelegate, CKCalendarDelegate>

@property(nonatomic, strong) IBOutlet MenuPanelView *menuPanel;
@property(nonatomic, strong) IBOutlet ProductPropertiesView * productProperties;
@property(nonatomic, strong) MenuCard *menuCard;

@property(nonatomic, strong) UIPopoverController *popover;

@property(nonatomic, strong) UIButton *calendarButton;

+ (MenuCardViewController *)controllerWithMenuCard:(MenuCard *)card;

@end
