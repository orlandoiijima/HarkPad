//
//  NewLocationViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import "NewLocationViewController.h"
#import "Service.h"
#import "CredentialsAlertView.h"

@interface NewLocationViewController ()

@end

@implementation NewLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)registerLocation {
    [CredentialsAlertView
        viewWithPincode: @"1234"
        afterDone: ^(Credentials *credentials)
            {
                [[Service getInstance]
                        createLocation: _locationName.text
                           credentials: credentials
                               success:nil
                               error:^(ServiceResult *result) {
                                   [result displayError];
                               }
                ];
                return;
            }
    ];
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
