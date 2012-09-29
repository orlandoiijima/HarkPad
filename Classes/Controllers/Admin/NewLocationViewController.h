//
//  NewLocationViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceResult.h"

@interface NewLocationViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (retain) IBOutlet UITextField *locationName;
@property (retain) IBOutlet UIButton *logoButton;
@property (retain) IBOutlet UIImageView *logoView;

@property(nonatomic, strong) UIPopoverController *popover;

- (IBAction) selectLogo;

- (IBAction) registerLocation;


@end
