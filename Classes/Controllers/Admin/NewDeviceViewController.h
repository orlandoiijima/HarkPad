//
//  NewDeviceViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectItemDelegate.h"

@interface NewDeviceViewController : UIViewController <SelectItemDelegate>

- (IBAction) logIn;
- (IBAction) signOn;

@property (retain) IBOutlet UITextField *userField;
@property (retain) IBOutlet UITextField *passwordField;
@property (retain) IBOutlet UIButton *logInButton;
@property (retain) IBOutlet UIButton *signOnButton;

@end
