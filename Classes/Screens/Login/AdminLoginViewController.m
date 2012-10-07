//
//  AdminLoginViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdminLoginViewController.h"
#import "AppVault.h"

@interface AdminLoginViewController ()

@end

@implementation AdminLoginViewController
@synthesize userService = _userService;


+ (AdminLoginViewController *)controllerDidEnterAuthentication:(void (^)(Credentials *))didEnterCredentialsBlock didCancel:(void (^)(void))didCancel {
    AdminLoginViewController *controller = [[AdminLoginViewController alloc] init];
    controller.didEnterCredentialsBlock = didEnterCredentialsBlock;
    controller.didCancel = didCancel;
    controller.userService = [[UserService alloc] init];
    controller.contentSizeForViewInPopover = CGSizeMake(300, 400);
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
    self.title = NSLocalizedString(@"Login", <#comment#>);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(go)];

    [_emailField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)go {
    Credentials *credentials = [Credentials credentialsWithEmail:_emailField.text password:_passwordField.text pincode:[[Session credentials] pincode]];
    [Session setCredentials:credentials];
    self.didEnterCredentialsBlock(credentials);

//    [self.userService
//            authenticateWithEmail: _emailField.text
//                         password: _passwordField.text
//                     progressInfo: [ProgressInfo progressWithActivityText:NSLocalizedString(@"Verifying...", nil) label:_indicatorLabel activityIndicatorView: _indicatorView]
//                    authenticated:^(NSString *pin) {
//                                    if (pin != nil) {
//                                        [self didAuthenticate: pin];
//                                    }
//    }];
}

//- (void) didAuthenticate: (NSString *)pin {
//    Credentials *credentials = [Credentials credentialsWithEmail:_emailField.text password:_passwordField.text pincode:pin];
//    [Session setCredentials:credentials];
//    self.didEnterCredentialsBlock(credentials);
//}

@end
