//
//  ProductPropertiesView.h
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "ItemPropertiesDelegate.h"
#import "ColorViewController.h"

@interface ProductPropertiesView : UIView <ColorViewControllerDelegate> {
    UITextField *uiKey;
    UITextField *uiName;
    UITextField *uiPrice;
    UISegmentedControl *uiVat;
    id<ItemPropertiesDelegate> __strong _delegate;
}

@property (retain) IBOutlet UITextField *uiKey;
@property (retain) IBOutlet UITextField *uiName;
@property (retain) IBOutlet UITextField *uiPrice;
@property (retain) IBOutlet UISegmentedControl *uiVat;
@property (nonatomic, retain) id<ItemPropertiesDelegate> delegate;
@property (retain) IBOutlet UIButton *uiColorButton;
@property (retain) IBOutlet UITextField *uiCategory;

@property(nonatomic, strong) Product *product;

@property(nonatomic, strong) UIPopoverController *popoverController;

@property(nonatomic, strong) NSMutableDictionary *vatPercentages;

- (IBAction) colorAction;

- (void)endEdit;

+ (ProductPropertiesView *)viewWithFrame:(CGRect)frame vatPercentages:(NSMutableArray *)vatPercentages;

- (bool) validate;

@end
