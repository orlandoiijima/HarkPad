//
//  MenuPropertiesView.h
//  HarkPad
//
//  Created by Willem Bison on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"
#import "ProductPanelView.h"

@class MenuCard;

@interface MenuPropertiesView : UIView <UITableViewDataSource, UITableViewDelegate, ProductPanelDelegate>

@property (retain) IBOutlet UITableView *productTable;
@property (retain) IBOutlet UITextField *nameField;
@property (retain) IBOutlet UITextField *keyField;
@property (retain) IBOutlet UITextField *priceField;
@property(nonatomic, strong) Menu * menu;

@property(nonatomic, strong) MenuCard *menuCard;

@property(nonatomic, strong) UIPopoverController *popover;

+ (MenuPropertiesView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard;

@end
