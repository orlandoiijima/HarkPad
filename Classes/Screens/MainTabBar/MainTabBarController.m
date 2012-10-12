//
//  MainTabBarController.m
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainTabBarController.h"
#import "TableMapViewController.h"
#import "Config.h"
#import "DashboardViewController.h"
#import "ReservationsViewController.h"
#import "ReservationsSimple.h"
#import "SalesViewController.h"
#import "WorkInProgressViewController.h"
#import "ChefViewController.h"
#import "LogViewController.h"
#import "IASKAppSettingsViewController.h"
#import "SimpleOrderScreen.h"
#import "LocationsViewController.h"
#import "MenuCardViewController.h"
#import "MenuCardListViewController.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[Cache getInstance] config] == nil) {
        [[Service getInstance] getConfig: ^(ServiceResult * serviceResult) {
                                [[Cache getInstance] loadFromJson: serviceResult.jsonData];
                                [self setupTabController];
                                }
                     error: ^(ServiceResult *serviceResult) {
                                [serviceResult displayError];
                                }
                    progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Loading configuration", nil) parentView: self.view]
        ];

    }
    else
        [self setupTabController];
}

- (void) setupTabController {

    Cache *cache = [Cache getInstance];

    NSArray *screens = [cache.config getObjectAtPath:@"Screens"];

    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for(NSString *screen in screens) {
        UIViewController *controller = nil;
        if ([screen isEqualToString:@"tables"]) {
            TableMapViewController *tableMapViewController = [[TableMapViewController alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: tableMapViewController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tables", nil) image:[UIImage imageNamed:@"fork-and-knife"] tag:1];
        }

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
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Orders", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if ([screen isEqualToString:@"bills"]) {
            InvoicesViewController *invoicesViewController = [[InvoicesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            controller = [[UINavigationController alloc] initWithRootViewController: invoicesViewController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Bills", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if ([screen isEqualToString:@"products"]) {
            controller = [[MenuCardListViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Products", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if ([screen isEqualToString:@"locations"]) {
            controller = [[LocationsViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Locations", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if (controller != nil) {
            [controllers addObject: controller];
        }
    }

    self.viewControllers = controllers;
}

@end
