//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BaseAdminViewController.h"
#import "AppVault.h"
#import "Session.h"
#import "Credentials.h"
#import "PinLoginViewController.h"
#import "Service.h"


@implementation BaseAdminViewController {

}
@synthesize loginViewController = _loginViewController;

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([Session isAuthenticatedAsAdmin] == false) {
        self.loginViewController = [PinLoginViewController controllerFullCredentialsRequired:YES onAuthenticated:^(Credentials *credentials) {
            [[Service getInstance]
                    registerDeviceWithCredentials:credentials
                                          success:^(ServiceResult *serviceResult) {
                                              [AppVault setDatabase:[serviceResult.jsonData objectForKey:@"database"]];
                                              [AppVault setDeviceKey:[serviceResult.jsonData objectForKey:@"deviceKey"]];
                                              [AppVault setLocationId:[[serviceResult.jsonData objectForKey:@"locationId"] intValue]];
                                              [AppVault setLocation:[serviceResult.jsonData objectForKey:@"location"]];
                                              [self.loginViewController dismissViewControllerAnimated:YES completion:nil];
                                          }
                                            error:^(ServiceResult *result) {
                                                [result displayError];
                                            }
            ];
        }                                                                           onCancel:nil];
        [self presentViewController: self.loginViewController animated:YES completion:nil];
    }
}

@end