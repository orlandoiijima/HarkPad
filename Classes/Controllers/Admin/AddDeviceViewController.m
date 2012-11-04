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
#import "EditLocationViewController.h"
#import "Location.h"
#import "MainTabBarController.h"

@interface AddDeviceViewController ()

@end

@implementation AddDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Register iPad", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(go)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addLocation {
    Location *location = [[Location alloc] init];
    EditLocationViewController *controller = [EditLocationViewController controllerWithLocation: location delegate:self];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didSaveItem:(id)item {
    Location *location = (Location *)item;
    if (location == nil) return;
    [[Service getInstance]
            createLocation: location
               credentials: [Session credentials]
                   success: ^(ServiceResult *serviceResult) {
                       [self.locationsView addLocation: location];
                       [self.navigationController popViewControllerAnimated:YES];
                   }
                     error:^(ServiceResult *result) {
                       [self.navigationController popViewControllerAnimated:YES];
                       [result displayError];
                   }
              progressInfo: [ProgressInfo progressWithHudText:NSLocalizedString(@"Registering location", nil) parentView:self.view]
    ];
}


- (IBAction)go {

    if (_locationsView.selectedLocationId == -1)
        return;

    [[Service getInstance]
            registerDeviceAtLocation: _locationsView.selectedLocationId
                     withCredentials: [Session credentials]
            success:^(ServiceResult *serviceResult) {
                [AppVault setDeviceKey:[serviceResult.jsonData objectForKey:@"deviceKey"]];

                MainTabBarController *controller = [[MainTabBarController alloc] init];
                [[[UIApplication sharedApplication] keyWindow] setRootViewController: controller];
            }
            error:^(ServiceResult *result) {
                [result displayError];
                }
         progressInfo: [ProgressInfo progressWithHudText:NSLocalizedString(@"Registering device", nil) parentView:self.view]
    ];
}

@end
