//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BaseAdminViewController.h"
#import "AppVault.h"
#import "Session.h"
#import "Credentials.h"
#import "Service.h"


@implementation BaseAdminViewController {

}
@synthesize loginViewController = _loginViewController;
@synthesize popoverController = _popover;


- (BOOL) requiresAdmin {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self requiresAdmin] == NO)
        return;
    if ([Session isAuthenticatedAsAdmin] == YES)
        return;
    _loginViewController = [AdminLoginViewController controllerDidEnterAuthentication:^(Credentials *credentials) {
        [_popover dismissPopoverAnimated:YES];
    }                                                                       didCancel:nil];

    self.view.userInteractionEnabled = NO;

    _popover = [[UIPopoverController alloc] initWithContentViewController:_loginViewController];
    _popover.delegate = self;
    [_popover presentPopoverFromRect: self.view.frame inView:self.view permittedArrowDirections:0 animated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return NO;
}

@end