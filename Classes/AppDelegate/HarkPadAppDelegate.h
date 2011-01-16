Misc reorg//
//  HarkPadAppDelegate.h
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableMapViewController;

@interface HarkPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TableMapViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TableMapViewController *viewController;

@end
