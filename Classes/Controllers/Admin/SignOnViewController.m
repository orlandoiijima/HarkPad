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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(signon)];
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
    return YES;
}

- (IBAction)signon {
    if ([self validate] == NO)
        return;
    Signon *signon = [[Signon alloc] init];
    signon.tenant = _organisation.text;
    signon.location = _organisation.text;
    signon.firstName = _firstName.text;
    signon.surName = _surName.text;
    signon.pinCode = _pincode.text;
    signon.email = _email.text;
    signon.password = _password.text;

    [[Service getInstance]
            signon:signon
           success: ^(ServiceResult *result) {
               NSString *deviceKey = [result.jsonData valueForKey:@"DeviceKey"];
               NSString *dataBase = [result.jsonData valueForKey:@"Database"];
               [AppVault setDeviceKey: deviceKey];
               [AppVault setDatabase:dataBase];
           }
             error:^(ServiceResult *serviceResult) {
                        [serviceResult displayError];
                    }
    ];
}
@end
