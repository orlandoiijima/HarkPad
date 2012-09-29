//
//  NewDeviceViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CredentialsAlertView;

@interface NewDeviceViewController : UIViewController

@property(nonatomic, strong) CredentialsAlertView *credentialsAlertView;

- (IBAction) registerDevice;
- (IBAction) signOnOrganisation;

@end
