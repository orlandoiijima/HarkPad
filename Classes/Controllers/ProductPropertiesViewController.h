//
//  ProductPropertiesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductPropertiesViewController : UIViewController {
    Product *product;
    UITextField *uiKey;
    UITextField *uiName;
    UITextView *uiDescription;
    UITextField *uiPrice;
}

@property (retain) Product *product;
@property (retain) IBOutlet UITextField *uiKey;
@property (retain) IBOutlet UITextField *uiName;
@property (retain) IBOutlet UITextView *uiDescription;
@property (retain) IBOutlet UITextField *uiPrice;
@property (retain) IBOutlet UIButton *uiCategory;
@property (retain) UIPopoverController *popoverController;

- (id) initWithProduct: (Product *)newProduct;

- (IBAction) saveAction;
- (IBAction) cancelAction;
- (IBAction) getCategoryAction;
- (bool) validate;

@end
