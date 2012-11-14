//
//  EditCompanyViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceResult.h"
#import "Service.h"
#import "Session.h"
#import "ItemPropertiesDelegate.h"
#import "Location.h"
#import "BaseAdminViewController.h"

@class Company;

@interface EditCompanyViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (retain) IBOutlet UITextField *companyName;

@property(nonatomic, strong) UIPopoverController *popover;

@property(nonatomic, strong) id<ItemPropertiesDelegate> delegate;

@property(nonatomic, strong) Company *company;

@property(nonatomic, strong) IBOutlet UILabel *logoLabel;
@property(nonatomic, strong) IBOutlet UIImageView * logoView;
@property(nonatomic, strong) IBOutlet UITextField *streetField;
@property(nonatomic, strong) IBOutlet UITextField *numberField;
@property(nonatomic, strong) IBOutlet UITextField *zipCodeField;
@property(nonatomic, strong) IBOutlet UITextField *cityField;
@property(nonatomic, strong) IBOutlet UITextField *phoneField;


+ (EditCompanyViewController *)controllerWithCompany:(Company *)company delegate:(id <ItemPropertiesDelegate>)delegate;


@end
