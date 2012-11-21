//
//  EditUserViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignOn.h"
#import "ItemPropertiesDelegate.h"
#import "User.h"

@interface EditUserViewController : UIViewController <ItemPropertiesDelegate>

@property (retain) IBOutlet UITextField *password;
@property (retain) IBOutlet UITextField *password2;
@property (retain) IBOutlet UITextField *firstName;
@property (retain) IBOutlet UITextField *surName;
@property (retain) IBOutlet UITextField *email;
@property (retain) IBOutlet UITextField *pinCode;

@property(nonatomic, strong) id<ItemPropertiesDelegate> delegate;
@property(nonatomic, strong) User *user;
@end
