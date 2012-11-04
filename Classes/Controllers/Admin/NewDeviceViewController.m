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
#import "LoginPinViewController.h"
#import "AddDeviceViewController.h"
#import "AdminLoginViewController.h"

@interface NewDeviceViewController ()

@end

@implementation NewDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)registerDevice {
//    AdminLoginViewController *controller = [AdminLoginViewController controllerDidEnterAuthentication:^(Credentials *credentials) {
//        AddDeviceViewController *addDeviceViewController = [[AddDeviceViewController alloc] init];
//        [self.navigationController pushViewController:addDeviceViewController animated:YES];
//    }
//                                                                                            didCancel:nil];
//    [self.navigationController pushViewController: controller animated:YES];

    AddDeviceViewController *addDeviceViewController = [[AddDeviceViewController alloc] init];
    [self.navigationController pushViewController:addDeviceViewController animated:YES];
}


- (IBAction)signOnOrganisation {
    SignOnViewController *controller  = [[SignOnViewController alloc] init];
    [self.navigationController pushViewController: controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"New device", <#comment#>);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
