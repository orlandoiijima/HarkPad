//
//  LoginPinViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginPinViewController.h"
#import "ProgressInfo.h"
#import "ServiceResult.h"
#import "Cache.h"
#import "MBProgressHUD.h"
#import "Service.h"
#import "AppVault.h"

@interface LoginPinViewController ()

@end

@implementation LoginPinViewController
@synthesize numberOfAttempts = _numberOfAttempts;
@synthesize didAuthenticateBlock = _didAuthenticateBlock;
@synthesize pinLabels = _pinLabels;
@synthesize captionField = _captionField;
@synthesize logoView = _logoView;
@synthesize name = _name;


#define PIN_WIDTH 70
#define PIN_SPACE 10


+ (LoginPinViewController *)controllerWithAuthenticatedBlock:(void (^)(User *))didAuthenticateBlock {
    LoginPinViewController *controller = [[LoginPinViewController alloc] init];
    controller.didAuthenticateBlock = didAuthenticateBlock;
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[Cache getInstance] isLoaded] == false)
        [self getConfig];

    self.numberOfAttempts = 0;

    _captionField = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 4 - 80, self.view.frame.size.width, 50)];
    _captionField.autoresizingMask = (UIViewAutoresizing) -1;
    [self.view addSubview:_captionField];
    _captionField.text = NSLocalizedString(@"Enter your accesskey", nil);
    _captionField.textAlignment = NSTextAlignmentCenter;
    _captionField.textColor = [UIColor whiteColor];
    _captionField.backgroundColor = [UIColor clearColor];
    _captionField.font = [UIFont systemFontOfSize:30];
    _captionField.alpha = 0;

    _pinField = [[UITextField alloc] initWithFrame:CGRectMake(-500, -500, 10, 10)];
    _pinField.keyboardType = UIKeyboardTypeNumberPad;
    [_pinField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview: _pinField];
    [_pinField becomeFirstResponder];

    float y = self.view.frame.size.height / 4;

    _pinLabels = [[NSMutableArray alloc] init];
    float x = (self.view.frame.size.width - 4 * PIN_WIDTH - 3 * PIN_SPACE) / 2;
    for (int j = 0; j < 4; j++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x + j * (PIN_WIDTH + PIN_SPACE), y, PIN_WIDTH, PIN_WIDTH)];
        view.alpha = 0;
        view.autoresizingMask = (UIViewAutoresizing) -1;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PIN_WIDTH, PIN_WIDTH)];
        [view addSubview:label];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.cornerRadius = 6;
        gradientLayer.frame = label.bounds;
        gradientLayer.borderColor = [[UIColor grayColor] CGColor];
        gradientLayer.borderWidth = 2;
        gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
        gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.4], [NSNumber numberWithFloat:1.0], nil];
        [view.layer insertSublayer:gradientLayer atIndex:0];

        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:32];
        [_pinLabels addObject:label];
        [self.view addSubview:view];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self arrangePinViews];
}

- (void) arrangePinViews {
    [UIView animateWithDuration:0.5 animations:^{
        _captionField.alpha = 1;
        for (int j = 0; j < 4; j++) {
            UILabel *label = [_pinLabels objectAtIndex:j];
            label.superview.alpha = 1;
        }
    }];
}

- (void) wrongPin {
    for (int j = 0; j < 4; j++) {
        UILabel *label = [_pinLabels objectAtIndex:j];
        [self shake:label];
    }
    _pinField.text = @"";
}

- (void) hidePin {
    for (int j = 0; j < 4; j++) {
        UILabel *label = [_pinLabels objectAtIndex:j];
        label.superview.hidden = YES;
    }
}

- (void)textChanged:(id)_textChanged {
    NSString *pin = _pinField.text;
    for (int j = 0; j < 4; j++) {
        UILabel *label = [_pinLabels objectAtIndex:j];
        label.text = [pin length] <= j ? @"" : @"●";
    }
    if([pin length] == 4)
        [self go];
}

- (void)shake:(UILabel*)itemView
{
    int distance = 20;
    CGPoint origin = itemView.center;

    [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
        itemView.center = CGPointMake(origin.x + arc4random()%distance - distance/2, origin.y + arc4random()%distance - distance/2);
    } completion:^(BOOL completed) {
    [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
        itemView.center = CGPointMake(origin.x + arc4random()%distance - distance/2, origin.y + arc4random()%distance - distance/2);
    } completion:^(BOOL completed2) {
    [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
        itemView.center = CGPointMake(origin.x + arc4random()%distance - distance/2, origin.y + arc4random()%distance - distance/2);
    } completion:^(BOOL completed3) {
    [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
        itemView.center = CGPointMake(origin.x + arc4random()%distance - distance/2, origin.y + arc4random()%distance - distance/2);
    } completion:^(BOOL completed4) {
    [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
        itemView.center = CGPointMake(origin.x + arc4random()%distance - distance/2, origin.y + arc4random()%distance - distance/2);
        itemView.alpha = 0.5;
    } completion:^(BOOL completed5) {
    [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
        itemView.center = CGPointMake(origin.x + arc4random()%distance - distance/2, origin.y + arc4random()%distance - distance/2);
        itemView.alpha = 0;
    } completion:^(BOOL completed6) {
        itemView.center = origin;
        itemView.text = @"";
        itemView.alpha = 1;
        }];
     }];
    }];
    }];
    }];}];
}

- (void) go {
    if (_isConfigLoaded == NO)
        return;
    UserService *service = [[UserService alloc] init];
    NSString *pin = _pinField.text;

    User *user = [service findUserWithPin: pin];
    if (user == nil) {
        [self wrongPin];
        self.numberOfAttempts++;
        if(self.numberOfAttempts == 3) {
            _pinField.enabled = NO;
        }
    }
    else {
        [self hidePin];
        _captionField.text = user.firstName;
        [self didAuthenticate:user];
    }
}

- (void) didAuthenticate: (User *)user {
    [Session setCredentials:[Credentials credentialsWithEmail:nil password:nil pinCode:user.pinCode]];
    self.didAuthenticateBlock( user);
}


- (void) getConfig
{
    Service *service = [Service getInstance];
    [service getConfig: ^(ServiceResult * serviceResult) {
                                _isConfigLoaded = YES;
                                [[Cache getInstance] loadFromJson: serviceResult.jsonData];
                                if (_pinField.text.length == 4) {
                                    [self go];
                                }
        [self showCompanyInfo];
                            }
                 error: ^(ServiceResult *serviceResult) {
                                [serviceResult displayError];
                                if (serviceResult.httpStatusCode  == 401) {
                                }
                            }
                progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Loading configuration", nil) parentView: self.view]
    ];
}

- (void)showCompanyInfo {
    Company *company =  [[Cache getInstance] company];
    if (company == nil) return;

    float topMargin = 20;
    float nameHeight = 30;
    float logoHeight = 0;
    float bottomMargin = 30;
    if (company.logo != nil) {
        logoHeight = _captionField.frame.origin.y - topMargin - nameHeight - bottomMargin;
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoHeight)/2, topMargin, logoHeight, logoHeight)];
        self.logoView.image = company.logo;
        self.logoView.alpha = 0;
        [self.view addSubview:self.logoView];
    }
    self.name = [[UILabel alloc] initWithFrame: CGRectMake(0, logoHeight + 10 + 10, self.view.frame.size.width, nameHeight)];
    self.name.textColor = [UIColor whiteColor];
    self.name.backgroundColor = [UIColor clearColor];
    self.name.alpha = 0;
    self.name.text = company.name;
    self.name.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.name];

    [UIView animateWithDuration:0.8 animations:^{
        self.logoView.alpha = 1;
        self.name.alpha = 1;
    }];
}

@end