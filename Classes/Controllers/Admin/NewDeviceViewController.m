//
//  NewDeviceViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import "NewDeviceViewController.h"
#import "SignOnViewController.h"
#import "CompanyListViewController.h"
#import "Company.h"
#import "Session.h"
#import "AppVault.h"

@interface NewDeviceViewController ()

@end

@implementation NewDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)logIn {
    Credentials *credentials = [Credentials credentialsWithEmail: _userField.text password:_passwordField.text pinCode:nil];
    [Session setCredentials:credentials];
    [[Service getInstance]
            requestResource:@"company"
                         id:nil
                     action:nil
                  arguments:nil
                       body:nil
                       verb:HttpVerbGet
                    success:^(ServiceResult *serviceResult) {[self logInCallback:serviceResult]; }
                      error:^(ServiceResult *serviceResult) {[serviceResult displayError]; }
               progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Loading...", nil) parentView:self.view]];
}

- (void) logInCallback:(ServiceResult *)serviceResult {
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *dictionary in serviceResult.jsonData) {
        Company *company = [[Company alloc] initWithDictionary:dictionary];
        [companies addObject:company];
    }
    CompanyListViewController *companyListViewController = [[CompanyListViewController alloc] init];
    companyListViewController.delegate = self;
    companyListViewController.companies = companies;
    [self.navigationController pushViewController: companyListViewController animated:YES];
}

- (IBAction)signOn {
    SignOnViewController *controller  = [[SignOnViewController alloc] init];
    [self.navigationController pushViewController: controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"New device", nil);
}

- (void)didSelectItem:(id)item {
    if ([item isKindOfClass:[Company class]] == NO) return;
    Company *company = (Company *)item;
    [AppVault setLocationId: company.locationId];
    [AppVault setAccountId: company.accountId];
    [AppVault setLocationName: company.name];
    [[Service getInstance]
            requestResource:@"device"
                         id:nil
                     action:nil
                  arguments:nil
                       body:nil
                       verb:HttpVerbPost
                    success:^(ServiceResult *result) {
                                [AppVault setDeviceId: [result.jsonData valueForKey:@"deviceId"]];
                            }
                      error:^(ServiceResult *result){}
               progressInfo:[ProgressInfo progressWithHudText:@"" parentView:self.view]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
