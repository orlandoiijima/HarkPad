//
//  EditUserViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignOn.h"

@interface EditUserViewController : UIViewController

@property (retain) IBOutlet UITextField *password;
@property (retain) IBOutlet UITextField *password2;
@property (retain) IBOutlet UITextField *firstName;
@property (retain) IBOutlet UITextField *surName;
@property (retain) IBOutlet UITextField *email;
@property (retain) IBOutlet UITextField *pinCode;

@property(nonatomic, strong) Signon *signOn;
@end
