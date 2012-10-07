//
//  EditLocationViewController.h
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

@interface EditLocationViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (retain) IBOutlet UITextField *locationName;

@property(nonatomic, strong) UIPopoverController *popover;

@property(nonatomic, strong) id<ItemPropertiesDelegate> delegate;

@property(nonatomic, strong) IBOutlet UILabel *logoLabel;

@property(nonatomic, strong) IBOutlet UIImageView * logoView;

@property(nonatomic, strong) Location *location;

+ (EditLocationViewController *)controllerWithLocation:(Location *)location delegate:(id <ItemPropertiesDelegate>)delegate;


@end
