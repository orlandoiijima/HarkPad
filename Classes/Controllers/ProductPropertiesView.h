//
//  ProductPropertiesView.h
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "MenuDelegate.h"
#import "ColorViewController.h"

@class MenuCard;

@interface ProductPropertiesView : UIView {
}

@property (retain) IBOutlet UITextField *uiKey;
@property (retain) IBOutlet UITextField *uiName;
@property (retain) IBOutlet UITextField *uiPrice;
@property (retain) IBOutlet UISegmentedControl *uiVat;
@property (nonatomic, retain) id<MenuDelegate> delegate;
@property (retain) IBOutlet UIButton *uiIncludedInQuickMenu;
@property (retain) IBOutlet UIButton *uiDelete;
@property(nonatomic, strong) Product *product;

@property(nonatomic, strong) UIPopoverController *popoverController;

@property(nonatomic, strong) MenuCard *menuCard;

- (IBAction) toggleQuickMenu;
- (IBAction) updateName;
- (IBAction) updateCode;
- (IBAction) updateVat;
- (IBAction) updatePrice;
- (IBAction) delete;

+ (ProductPropertiesView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard;

- (bool) validate;

@end
