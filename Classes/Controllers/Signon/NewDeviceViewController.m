//
//  NewDeviceViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import "NewDeviceViewController.h"
#import "SignOnViewController.h"
#import "CredentialsAlertView.h"
#import "AppVault.h"
#import "LoginViewController.h"

@interface NewDeviceViewController ()

@end

@implementation NewDeviceViewController
@synthesize credentialsAlertView = _credentialsAlertView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)registerDevice {
    LoginViewController *controller = [LoginViewController controllerFullCredentialsRequired:YES onAuthenticated:^(Credentials *credentials) {
        [[Service getInstance]
                registerDeviceWithCredentials: credentials
                success:^(ServiceResult *serviceResult) {
                    [AppVault setDatabase:[serviceResult.jsonData objectForKey:@"database"]];
                    [AppVault setDeviceKey:[serviceResult.jsonData objectForKey:@"deviceKey"]];
                    [AppVault setLocationId:[[serviceResult.jsonData objectForKey:@"locationId"] intValue]];
                    [AppVault setLocation:[serviceResult.jsonData objectForKey:@"location"]];
                }
                error:^(ServiceResult *result) {
                    [result displayError];
                }
        ];
    }];
    [self.navigationController pushViewController: controller animated:YES];
//    _credentialsAlertView = [CredentialsAlertView
//            viewWithPincode: @"1234"
//            afterDone: ^(Credentials *credentials)
//                {
//                    return;
//                }
//    ];

}


- (IBAction)signOnOrganisation {
    SignOnViewController *controller  = [[SignOnViewController alloc] init];
    [self.navigationController pushViewController: controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
