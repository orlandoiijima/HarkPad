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
#import "Location.h"
#import "MainTabBarController.h"

@interface AddDeviceViewController ()

@end

@implementation AddDeviceViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

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
    NewLocationViewController *controller = [[NewLocationViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didSaveItem:(id)item {
    Location *location = (Location *)item;
    if (location == nil) return;
    [self.locationsView addLocation: location];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)go {

    if (_locationsView.selectedLocationId == -1)
        return;

    [[Service getInstance]
            registerDeviceAtLocation: _locationsView.selectedLocationId
                     withCredentials: [Session credentials]
            success:^(ServiceResult *serviceResult) {
                [AppVault setDatabase:[serviceResult.jsonData objectForKey:@"database"]];
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
