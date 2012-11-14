//
//  SignOnViewController.h
//  HarkPad
//
//  Created by Willem Bison on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Service.h"

@interface SignOnViewController : UIViewController <UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate>

@property (retain) IBOutlet UITextField *organisation;
@property (retain) IBOutlet UITextField *ip;
@property (retain) IBOutlet UITextField *password;
@property (retain) IBOutlet UITextField *password2;
@property (retain) IBOutlet UITextField *firstName;
@property (retain) IBOutlet UITextField *surName;
@property (retain) IBOutlet UITextField *email;
@property (retain) IBOutlet UITextField *pincode;
@property (retain) IBOutlet UIButton *signonButton;
@property(nonatomic, strong) IBOutlet UIImageView * logoView;

@property(nonatomic, strong) UIPopoverController *popover;

- (IBAction)signOn;

@end
