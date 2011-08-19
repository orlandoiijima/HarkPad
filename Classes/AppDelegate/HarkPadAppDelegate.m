		//
//  HarkPadAppDelegate.m
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "HarkPadAppDelegate.h"

@implementation HarkPadAppDelegate

@synthesize window;

@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect  rect = [[UIScreen mainScreen] bounds];
    [window setFrame:rect];
    [window makeKeyAndVisible];

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


@end
