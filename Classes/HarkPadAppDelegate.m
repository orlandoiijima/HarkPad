//
//  HarkPadAppDelegate.m
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "HarkPadAppDelegate.h"

#import "HarkPadViewController.h"

@implementation HarkPadAppDelegate


@synthesize window;

@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
     
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Save data if appropriate.
}

- (void)dealloc {

    [window release];
    [viewController release];
    [super dealloc];
}

@end
