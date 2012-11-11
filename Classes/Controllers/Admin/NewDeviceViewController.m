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
//    Credentials *credentials = [Credentials credentialsWithEmail: _userField.text password:_passwordField.text pincode:@""];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
