//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "AdminLoginViewController.h"

@interface BaseAdminViewController : UIViewController <UIPopoverControllerDelegate>
@property(nonatomic, strong) AdminLoginViewController *loginViewController;

@property(nonatomic, strong) UIPopoverController *popoverController;

- (BOOL)requiresAdmin;

@end