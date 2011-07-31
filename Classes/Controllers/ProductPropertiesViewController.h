//
//  ProductPropertiesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductPropertiesViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    Product *product;
    UITextField *uiKey;
    UITextField *uiName;
    UITextField *uiPrice;
    UISegmentedControl *uiVat;
    UIPickerView *uiCategory;
    UIPopoverController *popoverController;
}

@property (retain) Product *product;
@property (retain) IBOutlet UITextField *uiKey;
@property (retain) IBOutlet UITextField *uiName;
@property (retain) IBOutlet UIPickerView *uiCategory;
@property (retain) IBOutlet UITextField *uiPrice;
@property (retain) IBOutlet UISegmentedControl *uiVat;
@property (retain) UIPopoverController *popoverController;

- (id) initWithProduct: (Product *)newProduct;

- (IBAction) saveAction;

- (ProductCategory *)categoryByRow:(int)row;

- (int)rowByCategory:(ProductCategory *)searchCategory;


- (IBAction) cancelAction;
- (bool) validate;

@end
