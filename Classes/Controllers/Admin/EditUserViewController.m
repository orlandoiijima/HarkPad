//
//  EditUserViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditUserViewController.h"
#import "Service.h"
#import "AppVault.h"
#import "ModalAlert.h"

@interface EditUserViewController ()

@end

@implementation EditUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    self.title = NSLocalizedString(@"Contact", nil);

    [_firstName becomeFirstResponder];
}

- (void) done {
    if ([self validate] == NO)
        return;
    _user.firstName = _firstName.text;
    _user.surName = _surName.text;
    _user.pinCode = _pinCode.text;
    _user.email = _email.text;
    _user.password = _password.text;

    if (_delegate != nil) {
        [self.delegate didSaveItem: _user];
    }
}

- (bool)validate {
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
    if ([_pinCode.text length] != 4) {
        [_pinCode becomeFirstResponder];
        return false;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
