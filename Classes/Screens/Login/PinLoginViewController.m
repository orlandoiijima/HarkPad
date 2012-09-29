//
//  PinLoginViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PinLoginViewController.h"
#import "UserService.h"
#import "User.h"
#import "AppVault.h"
#import "Session.h"

@interface PinLoginViewController ()

@end

@implementation PinLoginViewController
@synthesize numberOfAttempts = _numberOfAttempts;
@synthesize fullCredentialsRequired = _fullCredentialsRequired;
@synthesize didAuthenticateBlock = _didAuthenticateBlock;


+ (PinLoginViewController *)controllerWithAuthenticatedBlock:(void (^)(User *))didAuthenticateBlock onCancel:(void (^)(void))didCancel {
    PinLoginViewController *controller = [[PinLoginViewController alloc] init];
    controller.didAuthenticateBlock = didAuthenticateBlock;
    controller.didCancel = didCancel;
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

    self.numberOfAttempts = 0;

    _pinField = [[UITextField alloc]init];
    [_pinField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    _pinField.center = CGPointMake(-500,-500);
    [self.view addSubview: _pinField];
    [_pinField becomeFirstResponder];
}


//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [_pinField becomeFirstResponder];
//}


- (void)textChanged:(id)_textChanged {
    NSString *pin = _pinField.text;
    _pin1Field.text = [pin length] < 1 ? @"" : [NSString stringWithFormat:@"%c", [pin characterAtIndex:0]];
    _pin2Field.text = [pin length] < 2 ? @"" : [NSString stringWithFormat:@"%c", [pin characterAtIndex:1]];
    _pin3Field.text = [pin length] < 3 ? @"" : [NSString stringWithFormat:@"%c", [pin characterAtIndex:2]];
    _pin4Field.text = [pin length] < 4 ? @"" : [NSString stringWithFormat:@"%c", [pin characterAtIndex:3]];
}

- (void) fillPinFields: (NSString *)pin {
    _pinField.text = pin;
}

- (NSString *) getPinFromFields {
    return _pinField.text;
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
        [self didAuthenticate:user];
    }
}

- (void) didAuthenticate: (User *)user {
    [Session setAuthenticatedUser: user];
    self.didAuthenticateBlock( user);
}

@end
