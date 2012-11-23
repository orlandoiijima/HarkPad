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
#import "SimpleOrderScreen.h"
#import "MenuCardListViewController.h"
#import "PrinterListViewController.h"
#import "DebugViewController.h"

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

    NSArray *screens = [cache.config getDeviceObjectAtPath:@"Screens"];

    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for(NSString *sCreen in screens) {
        UIViewController *controller = nil;
        NSString *screen = [sCreen lowercaseString];
        if ([screen isEqualToString:@"tables"] ) {
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
            MenuCardListViewController *productsController = [[MenuCardListViewController alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: productsController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Menucard", nil) image:[UIImage imageNamed:@"order.png"] tag:2];
        }

        if ([screen isEqualToString:@"printers"]) {
            PrinterListViewController *printersController = [[PrinterListViewController alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: printersController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Printers", nil) image:[UIImage imageNamed:@"printer.png"] tag:2];
        }

        if (controller != nil) {
            [controllers addObject: controller];
        }
    }

    DebugViewController *debugViewController = [[DebugViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController: debugViewController];
    controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Debug", nil) image:[UIImage imageNamed:@"bug.png"] tag:2];
    [controllers addObject: controller];

    self.viewControllers = controllers;
}

@end
