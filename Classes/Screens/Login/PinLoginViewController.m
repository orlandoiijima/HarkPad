//
//  PinLoginViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PinLoginViewController.h"
#import "ProgressInfo.h"
#import "ServiceResult.h"
#import "Cache.h"
#import "MBProgressHUD.h"
#import "Service.h"
#import "AppVault.h"

@interface PinLoginViewController ()

@end

@implementation PinLoginViewController
@synthesize numberOfAttempts = _numberOfAttempts;
@synthesize didAuthenticateBlock = _didAuthenticateBlock;
@synthesize pinLabels = _pinLabels;
@synthesize captionField = _captionField;
@synthesize logoView = _logoView;
@synthesize name = _name;


#define PIN_WIDTH 70
#define PIN_SPACE 10


+ (PinLoginViewController *)controllerWithAuthenticatedBlock:(void (^)(User *))didAuthenticateBlock {
    PinLoginViewController *controller = [[PinLoginViewController alloc] init];
    controller.didAuthenticateBlock = didAuthenticateBlock;
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[Cache getInstance] isLoaded] == false)
        [self getConfig];

    self.numberOfAttempts = 0;

    _captionField = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
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
    for (int j = 0; j < 4; j++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, y, PIN_WIDTH, PIN_WIDTH)];
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
    _captionField.frame = CGRectMake(0, self.view.frame.size.height / 4 - 60, self.view.frame.size.width, 40);
    [UIView animateWithDuration:0.5 animations:^{
        _captionField.alpha = 1;
        float x = (self.view.frame.size.width - 4 * PIN_WIDTH - 3 * PIN_SPACE) / 2;
        for (int j = 0; j < 4; j++) {
            UILabel *label = [_pinLabels objectAtIndex:j];
            label.superview.center = CGPointMake(x + j * (PIN_WIDTH + PIN_SPACE) + PIN_WIDTH/2, label.superview.center.y);
        }
    }];
}

- (void) wrongPin {
    for (int j = 0; j < 4; j++) {
        UILabel *label = [_pinLabels objectAtIndex:j];
        [self shake:label];
    }
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
    CGFloat t = 2.0;

    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, t);

    itemView.transform = leftQuake;  // starting point

    [UIView animateWithDuration:0.07 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:5];
        itemView.transform = rightQuake; // end here & auto-reverse

    } completion:^(BOOL completed){
        itemView.transform = CGAffineTransformIdentity;
        itemView.text = @"";
        _pinField.text = @"";
    }];
}

- (void) go {
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
        _captionField.text = user.name;
        [self didAuthenticate:user];
    }
}

- (void) didAuthenticate: (User *)user {
    [Session setCredentials:[Credentials credentialsWithEmail:nil password:nil pincode:user.pin]];
    self.didAuthenticateBlock( user);
}


- (void) getConfig
{
    Service *service = [Service getInstance];
    [service getConfig: ^(ServiceResult * serviceResult) {
                            [[Cache getInstance] loadFromJson: serviceResult.jsonData];
        [self showLocationInfo];
                            }
                 error: ^(ServiceResult *serviceResult) {
                            [serviceResult displayError];
                            }
                progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Loading configuration", nil) parentView: self.view]
    ];
}

- (void)showLocationInfo {
    Location *location =  [[Cache getInstance] currentLocation];
    if (location == nil) return;

    float topMargin = 20;
    float nameHeight = 30;
    float logoHeight = 0;
    float bottomMargin = 30;
    if (location.logo != nil) {
        logoHeight = _captionField.frame.origin.y - topMargin - nameHeight - bottomMargin;
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoHeight)/2, topMargin, logoHeight, logoHeight)];
        self.logoView.image = location.logo;
        self.logoView.alpha = 0;
        [self.view addSubview:self.logoView];
    }
    self.name = [[UILabel alloc] initWithFrame: CGRectMake(0, logoHeight + 10 + 10, self.view.frame.size.width, nameHeight)];
    self.name.textColor = [UIColor whiteColor];
    self.name.backgroundColor = [UIColor clearColor];
    self.name.alpha = 0;
    self.name.text = location.name;
    self.name.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.name];

    [UIView animateWithDuration:0.8 animations:^{
        self.logoView.alpha = 1;
        self.name.alpha = 1;
    }];
}


@end