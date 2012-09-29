//
//  AddDeviceViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "ServiceResult.h"
#import "AppVault.h"
#import "Service.h"
#import "Session.h"
#import "LocationsView.h"
#import "NewLocationViewController.h"

@interface AddDeviceViewController ()

@end

@implementation AddDeviceViewController

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


/*
*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addLocation {
    NewLocationViewController *controller = [[NewLocationViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)go {

    if (_locations.selectedLocationId == -1)
        return;

    [[Service getInstance]
            registerDeviceAtLocation: _locations.selectedLocationId
                     withCredentials: [Session credentials]
            success:^(ServiceResult *serviceResult) {
                [AppVault setDatabase:[serviceResult.jsonData objectForKey:@"database"]];
                [AppVault setDeviceKey:[serviceResult.jsonData objectForKey:@"deviceKey"]];
            }
            error:^(ServiceResult *result) {
                [result displayError];
            }
    ];
}


@end
