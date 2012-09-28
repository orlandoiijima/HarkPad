//
//  LoginViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "UserService.h"
#import "User.h"
#import "AppVault.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize numberOfAttempts = _numberOfAttempts;
@synthesize fullCredentialsRequired = _fullCredentialsRequired;
@synthesize didAuthenticateBlock = _didAuthenticateBlock;


+ (LoginViewController *)controllerFullCredentialsRequired: (BOOL)fullCredentials onAuthenticated: (void (^)(Credentials *)) didAuthenticateBlock {
    LoginViewController *controller = [[LoginViewController alloc] init];
    controller.fullCredentialsRequired = fullCredentials;
    controller.didAuthenticateBlock = didAuthenticateBlock;
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

    if (_fullCredentialsRequired) {
        [self fillPinFields: [AppVault pinCode]];
        _credentialsPanel.alpha = 1;
    }
    else {
        _credentialsPanel.alpha = 0;
    }
    self.numberOfAttempts = 0;
}

- (void) fillPinFields: (NSString *)pin {
    _pin1Field.text = [NSString stringWithFormat:@"%c", [pin characterAtIndex:0]];
    _pin2Field.text = [NSString stringWithFormat:@"%c", [pin characterAtIndex:0]];
    _pin3Field.text = [NSString stringWithFormat:@"%c", [pin characterAtIndex:0]];
    _pin4Field.text = [NSString stringWithFormat:@"%c", [pin characterAtIndex:0]];
}

- (NSString *) getPinFromFields {
    return [NSString stringWithFormat:@"%@%@%@%@", _pin1Field.text, _pin2Field.text, _pin3Field.text, _pin4Field.text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)go {
    UserService *service = [[UserService alloc] init];
    NSString *pin = [self getPinFromFields];

    User *user = [service findUserWithPin: pin];
    if (user == nil) {
        self.numberOfAttempts++;
        if(self.numberOfAttempts == 3) {
            _goButton.enabled = NO;
        }
    }
    else {
        [self didAuthenticate];
        if (user.role == RoleAdmin && self.fullCredentialsRequired) {
            [service authenticateWithEmail:_emailField.text password:_passwordField.text pincode:pin authenticated:^(BOOL isAuthed) {
                if (isAuthed)
                    [self didAuthenticate];
            }];
        }
        else {
            [self didAuthenticate];
        }
    }
}

- (void) didAuthenticate {
    NSString *pin = [self getPinFromFields];

    [AppVault setPinCode: pin];
    if (_fullCredentialsRequired) {
        self.didAuthenticateBlock( [Credentials credentialsWithEmail:_emailField.text password:_passwordField.text pincode: pin]);
    }
    else {
        self.didAuthenticateBlock( [Credentials credentialsWithEmail: nil password: nil pincode: pin]);
    }
}

@end
