//
//  AdminLoginViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class Credentials;
@class User;
@class UserService;

@interface AdminLoginViewController : UIViewController

@property (retain) IBOutlet UITextField *emailField;
@property (retain) IBOutlet UITextField *passwordField;

@property(nonatomic, copy) void (^didAuthenticateBlock)(Credentials *);
@property(nonatomic, copy) void (^didCancel)(void);

@property(nonatomic, strong) UserService *userService;

+ (AdminLoginViewController *)controllerWithAuthenticatedBlock:(void (^)(Credentials *))didAuthenticateBlock onCancel:(void (^)(void))didCancel;

@end
