//
//  HarkPadAppDelegate.m
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "HarkPadAppDelegate.h"
#import "ReservationsSimple.h"
#import "ProductMaintenance.h"
#import "MenuTreeMaintenance.h"
#import "TableMapViewController.h"
#import "TestFlight.h"
#import "Config.h"
#import "SignOnViewController.h"
#import "AppVault.h"
#import "NewDeviceViewController.h"

@implementation HarkPadAppDelegate

@synthesize window;

@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect  rect = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame:rect];
    [window makeKeyAndVisible];

    [TestFlight takeOff:@"64c7394c3f8507999809cd493b267759_NjkxNDQyMDEyLTAzLTA4IDA3OjU2OjI4LjI4MDQwOQ"];

    tabBarController = [[UITabBarController alloc] init];
    [window addSubview:tabBarController.view];

    if ([AppVault isDeviceRegistered] == false) {
        NewDeviceViewController *signOnController = [[NewDeviceViewController alloc] init];
        UIViewController *controller = [[UINavigationController alloc] initWithRootViewController: signOnController];
        controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Signon", nil) image:[UIImage imageNamed:@"fork-and-knife"] tag:1];

        tabBarController.viewControllers = [NSArray arrayWithObject:controller];
        return YES;
    }

    [self getConfig];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingChanged:)
                                                 name: kIASKAppSettingChanged object:nil];
    
    return YES;
}
- (void) settingChanged: (NSNotification *)notification {
    [Service clear];
    [self getConfig];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (BOOL) checkReachability {
    return [[Service getInstance] checkReachability];
}

- (void) getConfig
{
    Service *service = [Service getInstance];

    [MBProgressHUD showProgressAddedTo: tabBarController.view withText:[NSString stringWithFormat: NSLocalizedString(@"Loading configuration", nil)]];
    
    if ([service checkReachability] == NO) {
        [MBProgressHUD hideHUDForView:tabBarController.view animated:YES];
        NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"Service unavailable at %@", nil), service.host];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil];
        [view show];
        return;
    }
    [service getConfig: ^(ServiceResult * serviceResult) {
                        [self setupBarControllerCallback:serviceResult];
                    }
                 error:^(ServiceResult *serviceResult) {
                     [self setupBarControllerCallback:serviceResult];
                 }];
}

- (void) setupBarControllerCallback: (ServiceResult *)result
{
    [MBProgressHUD hideHUDForView:tabBarController.view animated:YES];

    Cache *cache = [Cache getInstance];

    if (result.isSuccess == false) {
        [result displayError];
        IASKAppSettingsViewController *settingsViewController = [[IASKAppSettingsViewController alloc] init];
        UIViewController *controller = [[UINavigationController alloc] initWithRootViewController: settingsViewController];
        controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"20-gear2.png"] tag:2];
        tabBarController.viewControllers = [NSArray arrayWithObject:controller];
        return;
    }

    [cache loadFromJson: result.jsonData];

    NSArray *screens = [cache.config getObjectAtPath:@"Screens"];

    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for(NSString *screen in screens) {
        UIViewController *controller = nil;
        if ([screen isEqualToString:@"tables"]) {
            TableMapViewController *tableMapViewController = [[TableMapViewController alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: tableMapViewController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tables", nil) image:[UIImage imageNamed:@"fork-and-knife"] tag:1];
        }

//        if ([key isEqualToString:@"order"]) {
//            controller = [[NewOrderViewController alloc] init];
//            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Order", nil) image:[UIImage imageNamed:@"food"] tag:1];
//        }
//
        if ([screen isEqualToString:@"dashboard"]) {
            controller = [[DashboardViewController alloc] initWithStyle:UITableViewStyleGrouped];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Dashboard", nil) image:[UIImage imageNamed:@"dashboard"] tag:1];
        }

        if ([screen isEqualToString:@"chef"]) {
            controller = [[ChefViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chef" image:[UIImage imageNamed:@"star"] tag:1];
        }

        if ([screen isEqualToString:@"inprogress"]) {
            controller = [[WorkInProgressViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Serve", nil) image:[UIImage imageNamed:@"food"] tag:1];
        }

        if ([screen isEqualToString:@"sales"]) {
            controller = [[SalesViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Sales", nil) image:[UIImage imageNamed:@"creditcard"] tag:1];
        }

        if ([screen isEqualToString:@"reservations"]) {
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                ReservationsSimple *reservationsController = [[ReservationsSimple alloc] init];
                controller = [[UINavigationController alloc] initWithRootViewController: reservationsController];
            }
            else
            {
                controller = [[ReservationsViewController alloc] init];
            }
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Reservations", nil) image:[UIImage imageNamed:@"calendar"] tag:1];
        }

        if ([screen isEqualToString:@"log"]) {
            controller = [[LogViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Log" image:[UIImage imageNamed:@"bug"] tag:1];
        }

        if ([screen isEqualToString:@"settings"]) {
            IASKAppSettingsViewController *settingsViewController = [[IASKAppSettingsViewController alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: settingsViewController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"20-gear2.png"] tag:2];
        }

        if ([screen isEqualToString:@"quickorder"]) {
            SimpleOrderScreen *simpleOrderScreen = [[SimpleOrderScreen alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: simpleOrderScreen];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Quick" image:[UIImage imageNamed:@"fork-and-knife"] tag:2];
        }
        
        if ([screen isEqualToString:@"orders"]) {
            SelectOpenOrder *selectOpenOrder = [[SelectOpenOrder alloc] initWithType:typeOverview title: NSLocalizedString(@"Running orders", nil)];
            controller = [[UINavigationController alloc] initWithRootViewController: selectOpenOrder];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Bills", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if ([screen isEqualToString:@"bills"]) {
            InvoicesViewController *invoicesViewController = [[InvoicesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            controller = [[UINavigationController alloc] initWithRootViewController: invoicesViewController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Bills", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if ([screen isEqualToString:@"products"]) {
            controller = [[ProductMaintenance alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Products", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if ([screen isEqualToString:@"menutree"]) {
            controller = [[MenuTreeMaintenance alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Menu", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if (controller != nil) {
            [controllers addObject: controller];
        }
    }

    tabBarController.viewControllers = controllers;
}

@end
