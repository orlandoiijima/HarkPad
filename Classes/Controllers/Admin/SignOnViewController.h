//
//  SignOnViewController.h
//  HarkPad
//
//  Created by Willem Bison on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Service.h"
#import "ItemPropertiesDelegate.h"

@interface SignOnViewController : UIViewController <UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, ItemPropertiesDelegate>

@property (retain) IBOutlet UITextField *organisation;
@property(nonatomic, strong) IBOutlet UIImageView * logoView;
@property(nonatomic, strong) UIPopoverController *popover;

@property(nonatomic) BOOL isLogoSet;
@property(nonatomic, strong) SignOn * signOn;
@end
