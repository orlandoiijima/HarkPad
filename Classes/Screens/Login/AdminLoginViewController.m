//
//  AdminLoginViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdminLoginViewController.h"
#import "Credentials.h"
#import "User.h"
#import "Session.h"
#import "UserService.h"

@interface AdminLoginViewController ()

@end

@implementation AdminLoginViewController
@synthesize userService = _userService;


+ (AdminLoginViewController *)controllerWithAuthenticatedBlock:(void (^)(Credentials *))didAuthenticateBlock onCancel:(void (^)(void))didCancel {
    AdminLoginViewController *controller = [[AdminLoginViewController alloc] init];
    controller.didAuthenticateBlock = didAuthenticateBlock;
    controller.didCancel = didCancel;
    controller.userService = [[UserService alloc] init];
    return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_emailField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)go {
    [self.userService authenticateWithEmail:_emailField.text password:_passwordField.text  authenticated:^(NSString *pin) {
        if (pin != nil) {
            [self didAuthenticate: pin];
        }
    }];
}

- (void) didAuthenticate: (NSString *)pin {
    Credentials *credentials = [Credentials credentialsWithEmail:_emailField.text password:_passwordField.text pincode:pin];
    [Session setCredentials:credentials];
    self.didAuthenticateBlock(credentials);
}

@end
