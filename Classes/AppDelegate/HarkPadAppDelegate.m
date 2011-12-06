//
//  HarkPadAppDelegate.m
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "HarkPadAppDelegate.h"

@implementation HarkPadAppDelegate

@synthesize window, toast;

@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect  rect = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame:rect];
    [window makeKeyAndVisible];

    tabBarController = [[UITabBarController alloc] init];
    [window addSubview:tabBarController.view];

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

    // Save data if appropriate.
}

- (void) getConfig
{
    toast = [iToast makeText:NSLocalizedString(@"Loading configuration", nil)];
    [toast showWithActivityIndicator:YES];

    [[Service getInstance] getDeviceConfig:self callback:@selector(setupBarControllerCallback:)];
}

- (void) setupBarControllerCallback: (ServiceResult *)result
{
    [toast hideToast];

    Cache *cache = [Cache getInstance];
    cache.config = result.jsonData;
    
    if (result.isSuccess == false) {
        [ModalAlert inform:result.error];
        return;
    }

    NSDictionary *ipad = [result.jsonData objectForKey:@"ipad"];
    NSDictionary * screen = [ipad objectForKey:@"screen"];

    NSMutableDictionary *controllers = [[NSMutableDictionary alloc] init];
    for(NSString *key in screen.allKeys) {
        UIViewController *controller = nil;
        if ([key isEqualToString:@"tables"]) {
            TableMapViewController *tableMapViewController = [[TableMapViewController alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: tableMapViewController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tables", nil) image:[UIImage imageNamed:@"fork-and-knife"] tag:1];
        }

        if ([key isEqualToString:@"dashboard"]) {
            controller = [[DashboardViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Dashboard", nil) image:[UIImage imageNamed:@"dashboard"] tag:1];
        }

        if ([key isEqualToString:@"chef"]) {
            controller = [[ChefViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chef" image:[UIImage imageNamed:@"star"] tag:1];
        }

        if ([key isEqualToString:@"inprogress"]) {
            controller = [[WorkInProgressViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Serve", nil) image:[UIImage imageNamed:@"food"] tag:1];
        }

        if ([key isEqualToString:@"sales"]) {
            controller = [[SalesViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Sales", nil) image:[UIImage imageNamed:@"creditcard"] tag:1];
        }

        if ([key isEqualToString:@"reservations"]) {
            controller = [[ScrollTableViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Reservations", nil) image:[UIImage imageNamed:@"calendar"] tag:1];
        }

        if ([key isEqualToString:@"log"]) {
            controller = [[LogViewController alloc] init];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Log" image:[UIImage imageNamed:@"bug"] tag:1];
        }

        if ([key isEqualToString:@"settings"]) {
            IASKAppSettingsViewController *settingsViewController = [[IASKAppSettingsViewController alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: settingsViewController];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@""] tag:2];
        }

        if ([key isEqualToString:@"quickorder"]) {
            SimpleOrderScreen *simpleOrderScreen = [[SimpleOrderScreen alloc] init];
            controller = [[UINavigationController alloc] initWithRootViewController: simpleOrderScreen];
            controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Quick" image:[UIImage imageNamed:@"fork-and-knife"] tag:2];
        }
        
        if (controller != nil) {
            NSDictionary *screenName = [screen objectForKey:key];
            NSString *index = [screenName objectForKey:@"index"];
            [controllers setObject:controller forKey:index];
        }
    }

    id sortedIndices = [[controllers allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *sortedControllers = [[NSMutableArray alloc] init];
    for(NSString *key in sortedIndices)
        [sortedControllers addObject:[controllers objectForKey:key]];
    tabBarController.viewControllers = sortedControllers;
}

@end
