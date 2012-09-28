//
//  HarkPadAppDelegate.h
//  HarkPad
//
//  Created by Willem Bison on 15-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IASKSettingsReader.h"
#import "Service.h"
#import "TableMapViewController.h"
#import "SimpleOrderScreen.h"
#import "ModalAlert.h"
#import "ChefViewController.h"
#import "DashboardViewController.h"
#import "SalesViewController.h"
#import "WorkInProgressViewController.h"
#import "../Screens/Reservations/ReservationsViewController.h"
#import "LogViewController.h"
#import "IASKAppSettingsViewController.h"
#import "MBProgressHUD.h"

@class TableMapViewController;
@class LoginViewController;

@interface HarkPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
    LoginViewController *loginViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UITabBarController *loginViewController;

- (void) getConfig;
- (BOOL) checkReachability;

@end
