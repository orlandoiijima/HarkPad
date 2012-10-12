//
//  HarkPadAppDelegate.m
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "HarkPadAppDelegate.h"
#import "ReservationsSimple.h"
#import "TestFlight.h"
#import "Config.h"
#import "AppVault.h"
#import "NewDeviceViewController.h"
#import "PinLoginViewController.h"
#import "MainTabBarController.h"

@implementation HarkPadAppDelegate

@synthesize window;

@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect  rect = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame:rect];
    [window makeKeyAndVisible];

    [TestFlight takeOff:@"64c7394c3f8507999809cd493b267759_NjkxNDQyMDEyLTAzLTA4IDA3OjU2OjI4LjI4MDQwOQ"];

    if ([AppVault isDeviceRegistered] == false) {
        NewDeviceViewController *signOnController = [[NewDeviceViewController alloc] init];
        UIViewController *controller = [[UINavigationController alloc] initWithRootViewController: signOnController];
        window.rootViewController = controller;
        [window addSubview:controller.view];
        return YES;
    }

    loginViewController = [PinLoginViewController controllerWithAuthenticatedBlock:^(User *user) {
        MainTabBarController *controller = [[MainTabBarController alloc] init];
        [window.rootViewController presentViewController:controller animated:YES completion:nil];
        }];
    window.rootViewController = loginViewController;
    [window addSubview: loginViewController.view];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (BOOL) checkReachability {
    return [[Service getInstance] checkReachability];
}
@end
