//
//  LoginViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Credentials.h"


@interface LoginViewController : UIViewController

@property (retain) IBOutlet UIButton *pin1Field;
@property (retain) IBOutlet UITextField *pin2Field;
@property (retain) IBOutlet UITextField *pin3Field;
@property (retain) IBOutlet UITextField *pin4Field;

@property (retain) IBOutlet UITextField *emailField;
@property (retain) IBOutlet UITextField *passwordField;
@property (retain) IBOutlet UIButton *goButton;
@property (retain) IBOutlet UIActivityIndicatorView *activityView;
@property (retain) IBOutlet UIView *credentialsPanel;

@property(nonatomic) int numberOfAttempts;

@property(nonatomic) BOOL fullCredentialsRequired;

@property(nonatomic, copy) void (^didAuthenticateBlock)(Credentials *);

+ (LoginViewController *)controllerFullCredentialsRequired:(BOOL)fullCredentials onAuthenticated:(void (^)(Credentials *))didAuthenticateBlock;

- (void)fillPinFields:(NSString *)pin;

- (NSString *)getPinFromFields;

- (IBAction) go;
@end
