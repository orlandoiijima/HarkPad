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
@protocol ItemPropertiesDelegate;
@protocol MenuDelegate;

@interface MenuPropertiesView : UIView <UITableViewDataSource, UITableViewDelegate, ProductPanelDelegate>

@property (retain) IBOutlet UITableView *productTable;
@property (retain) IBOutlet UITextField *nameField;
@property (retain) IBOutlet UITextField *keyField;
@property (retain) IBOutlet UITextField *priceField;
@property (retain) IBOutlet UIButton *uiDelete;
@property (retain) IBOutlet UIButton *includedInQuickMenu;
@property (nonatomic, retain) id<MenuDelegate> delegate;
@property(nonatomic, strong) Menu * menu;

@property(nonatomic, strong) MenuCard *menuCard;

@property(nonatomic, strong) UIPopoverController *popover;

- (IBAction)toggleQuickMenu;
- (IBAction) delete;
- (IBAction)updateName;
- (IBAction) updateCode;
- (IBAction) updatePrice;

+ (MenuPropertiesView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard;

@end
