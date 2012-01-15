//
//  ProductPropertiesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "ItemPropertiesDelegate.h"

@interface ProductPropertiesViewController : UIViewController {
    Product *product;
    UITextField *uiKey;
    UITextField *uiName;
    UITextField *uiPrice;
    UISegmentedControl *uiVat;
    id<ItemPropertiesDelegate> __strong _delegate;
}

@property (retain) Product *product;
@property (retain) IBOutlet UITextField *uiKey;
@property (retain) IBOutlet UITextField *uiName;
@property (retain) IBOutlet UITextField *uiPrice;
@property (retain) IBOutlet UISegmentedControl *uiVat;
@property (nonatomic, retain) id<ItemPropertiesDelegate> delegate;

- (id)initWithProduct:(Product *)newProduct delegate: (id<ItemPropertiesDelegate>) newDelegate;

- (IBAction) saveAction;
- (IBAction) cancelAction;
- (bool) validate;

@end
