//
//  CategoryPropertiesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 01/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "ProductCategory.h"
#import "HRColorPickerView.h"

@protocol ItemPropertiesDelegate;

@interface CategoryPropertiesViewController : UIViewController {
    
}

@property (retain) ProductCategory *category;

@property (retain) IBOutlet HRColorPickerView *uiColor;
@property (retain) IBOutlet UIView  *uiColorSliderPlaceHolder;
@property (retain) IBOutlet UITextField *uiName;
@property (nonatomic, retain) id<ItemPropertiesDelegate> delegate;

- (id)initWithCategory:(ProductCategory *)newProduct delegate: (id<ItemPropertiesDelegate>) newDelegate;

- (IBAction) saveAction;
- (IBAction) cancelAction;
- (bool) validate;

@end
