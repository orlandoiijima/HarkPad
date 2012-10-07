//
//  AdminLoginViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "Credentials.h"
#import "Session.h"
#import "UserService.h"
#import "ProgressInfo.h"

@interface AdminLoginViewController : UIViewController

@property (retain) IBOutlet UITextField *emailField;
@property (retain) IBOutlet UITextField *passwordField;
@property (retain) IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain) IBOutlet UILabel *indicatorLabel;
@property (retain) IBOutlet UIButton *loginButton;

@property(nonatomic, copy) void (^didEnterCredentialsBlock)(Credentials *);
@property(nonatomic, copy) void (^didCancel)(void);

@property(nonatomic, strong) UserService *userService;

+ (AdminLoginViewController *)controllerDidEnterAuthentication:(void (^)(Credentials *))didEnterCredentialsBlock didCancel:(void (^)(void))didCancel;

@end
