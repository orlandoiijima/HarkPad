//
//  AdminLoginViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class Credentials;
@class User;

@interface AdminLoginViewController : UIViewController

@property (retain) IBOutlet UITextField *emailField;
@property (retain) IBOutlet UITextField *passwordField;

@property(nonatomic, copy) void (^didAuthenticateBlock)(User *, Credentials *);

+ (AdminLoginViewController *)controller:(void (^)(User *,Credentials *))didAuthenticateBlock onCancel:(void (^)(void))didCancel;

@end
