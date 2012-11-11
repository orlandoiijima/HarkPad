//
//  SignOnViewController.m
//  HarkPad
//
//  Created by Willem Bison on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignOnViewController.h"
#import "Signon.h"
#import "KeychainWrapper.h"
#import "AppVault.h"

@interface SignOnViewController ()

@end

@implementation SignOnViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Sign up", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(signOn)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (bool)validate {
    if ([_organisation.text length] == 0) {
        [_organisation becomeFirstResponder];
        return false;
    }
    if ([_firstName.text length] == 0) {
        [_firstName becomeFirstResponder];
        return false;
    }
    if ([_surName.text length] == 0) {
        [_surName becomeFirstResponder];
        return false;
    }
    if ([_email.text length] == 0) {
        [_email becomeFirstResponder];
        return false;
    }
    if ([_password.text length] == 0) {
        [_password becomeFirstResponder];
        return false;
    }
    if ([_password.text isEqualToString:_password2.text] == false) {
        [_password2 becomeFirstResponder];
        return false;
    }
    if ([_pincode.text length] != 4) {
        [_pincode becomeFirstResponder];
        return false;
    }
    return YES;
}

- (IBAction)signOn {
    if ([self validate] == NO)
        return;
    Signon *signOn = [[Signon alloc] init];
    signOn.tenant = _organisation.text;
    signOn.firstName = _firstName.text;
    signOn.surName = _surName.text;
    signOn.pinCode = _pincode.text;
    signOn.email = _email.text;
    signOn.password = _password.text;

    [[Service getInstance]
            signon:signOn
           success: ^(ServiceResult *result) {
               [AppVault setDeviceId: [result.jsonData valueForKey:@"deviceId"]];
               [AppVault setAccountId: [result.jsonData valueForKey:@"accountId"]];
               [AppVault setLocationId: [result.jsonData valueForKey:@"locationId"]];
           }
             error:^(ServiceResult *serviceResult) {
                        [serviceResult displayError];
                    }
    ];
}
@end
