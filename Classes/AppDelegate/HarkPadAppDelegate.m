		//
//  HarkPadAppDelegate.m
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "HarkPadAppDelegate.h"
#import "TableMapViewController.h"

@implementation HarkPadAppDelegate


@synthesize window;

@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect  rect = [[UIScreen mainScreen] bounds];
    [window setFrame:rect];
    [viewController.view setFrame:rect];
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
