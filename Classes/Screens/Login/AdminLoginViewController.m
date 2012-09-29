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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)go {
    UserService *service = [[UserService alloc] init];
    [service authenticateWithEmail:_emailField.text password:_passwordField.text  authenticated:^(NSString *pin) {
        if (pin != nil) {
            User *user = [service findUserWithPin: pin];
            [self didAuthenticate: user];
        }
    }];
}

- (void) didAuthenticate: (User *)user {
    [Session setIsAuthenticatedAsAdmin: YES];
    self.didAuthenticateBlock(user, [Credentials credentialsWithEmail:_emailField.text password:_passwordField.text pincode: user.pin]);
}

@end
