//
//  HarkPadAppDelegate.h
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HarkPadViewController;

@interface HarkPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    HarkPadViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet HarkPadViewController *viewController;

@end
