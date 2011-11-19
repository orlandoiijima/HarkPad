		//
//  HarkPadAppDelegate.m
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "HarkPadAppDelegate.h"
#import "TableMapViewController.h"
#import "SimpleOrderScreen.h"
#import "ModalAlert.h"
#import "ChefViewController.h"
#import "DashboardViewController.h"
#import "SalesViewController.h"
#import "WorkInProgressViewController.h"
#import "ScrollTableViewController.h"
#import "LogViewController.h"
#import "IASKAppSettingsViewController.h"

@implementation HarkPadAppDelegate

@synthesize window;

@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect  rect = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame:rect];
    [window makeKeyAndVisible];

    [self getConfig];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingChanged:)
                                                 name: kIASKAppSettingChanged object:nil];
    
    return YES;
}
- (void) settingChanged: (NSNotification *)notification {
    [Service clear];
}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Save data if appropriate.
}

- (void) getConfig
{
    [[Service getInstance] getDeviceConfig:self callback:@selector(setupBarControllerCallback:)];
}

- (void) setupBarControllerCallback: (ServiceResult *)result
{
    Cache *cache = [Cache getInstance];
    cache.config = result.jsonData;
    
    if (result.isSuccess == false) {
        [ModalAlert inform:result.error];
        return;
    }

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [window addSubview:tabBarController.view];

    NSDictionary *ipad = [result.jsonData objectForKey:@"ipad"];
    NSDictionary * screen = [ipad objectForKey:@"screen"];

    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for(NSString *key in screen.allKeys) {

        if ([key isEqualToString:@"tables"]) {
            TableMapViewController *tableMapViewController = [[TableMapViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: tableMapViewController];
            navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tafels" image:[UIImage imageNamed:@"fork-and-knife"] tag:1];
            [controllers addObject: navigationController];
        }

        if ([key isEqualToString:@"dashboard"]) {
            DashboardViewController *dashboardViewController = [[DashboardViewController alloc] init];
            dashboardViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dashboard" image:[UIImage imageNamed:@"dashboard"] tag:1];
            [controllers addObject: dashboardViewController];
        }

        if ([key isEqualToString:@"chef"]) {
            ChefViewController *chefViewController = [[ChefViewController alloc] init];
            chefViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chef" image:[UIImage imageNamed:@"star"] tag:1];
            [controllers addObject: chefViewController];
        }

        if ([key isEqualToString:@"inprogress"]) {
            WorkInProgressViewController *inprogressViewController = [[WorkInProgressViewController alloc] init];
            inprogressViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Serveren" image:[UIImage imageNamed:@"food"] tag:1];
            [controllers addObject: inprogressViewController];
        }

        if ([key isEqualToString:@"sales"]) {
            SalesViewController *salesViewController = [[SalesViewController alloc] init];
            salesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sales" image:[UIImage imageNamed:@"creditcard"] tag:1];
            [controllers addObject: salesViewController];
        }

        if ([key isEqualToString:@"reservations"]) {
            ScrollTableViewController *reservationsViewController = [[ScrollTableViewController alloc] init];
            reservationsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Reserveringen" image:[UIImage imageNamed:@"calendar"] tag:1];
            [controllers addObject: reservationsViewController];
        }

        if ([key isEqualToString:@"log"]) {
            LogViewController *logViewController = [[LogViewController alloc] init];
            logViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Log" image:[UIImage imageNamed:@"bug"] tag:1];
            [controllers addObject: logViewController];
        }

        if ([key isEqualToString:@"settings"]) {
            IASKAppSettingsViewController *settingsViewController = [[IASKAppSettingsViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: settingsViewController];
            navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@""] tag:2];
            [controllers addObject:navigationController];
        }

        if ([key isEqualToString:@"quickorder"]) {
            SimpleOrderScreen *simpleOrderScreen = [[SimpleOrderScreen alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: simpleOrderScreen];
            navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Quick" image:[UIImage imageNamed:@"fork-and-knife"] tag:2];
            [controllers addObject:navigationController];
        }
    }

    tabBarController.viewControllers = controllers;
    self.viewController = tabBarController;
}

@end
