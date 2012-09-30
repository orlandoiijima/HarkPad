//
//  PinLoginViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PinLoginViewController.h"

@interface PinLoginViewController ()

@end

@implementation PinLoginViewController
@synthesize numberOfAttempts = _numberOfAttempts;
@synthesize didAuthenticateBlock = _didAuthenticateBlock;
@synthesize pinLabels = _pinLabels;

#define PIN_WIDTH 70
#define PIN_SPACE 10


+ (PinLoginViewController *)controllerWithAuthenticatedBlock:(void (^)(User *))didAuthenticateBlock onCancel:(void (^)(void))didCancel {
    PinLoginViewController *controller = [[PinLoginViewController alloc] init];
    controller.didAuthenticateBlock = didAuthenticateBlock;
    controller.didCancel = didCancel;
    return controller;
}

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

    self.numberOfAttempts = 0;

    _pinField = [[UITextField alloc]init];
    _pinField.keyboardType = UIKeyboardTypeNumberPad;
    [_pinField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    _pinField.center = CGPointMake(-500,-500);
    [self.view addSubview: _pinField];
    [_pinField becomeFirstResponder];

    _pinLabels = [[NSMutableArray alloc] init];
    for (int j = 0; j < 4; j++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PIN_WIDTH, PIN_WIDTH)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PIN_WIDTH, PIN_WIDTH)];
        [view addSubview:label];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.cornerRadius = 3;
        gradientLayer.frame = label.bounds;
        gradientLayer.borderColor = [[UIColor blackColor] CGColor];
        gradientLayer.borderWidth = 1;
        gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1] CGColor], nil];
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
    [UIView animateWithDuration:0.5 animations:^{
        float x = (self.view.frame.size.width - 4 * PIN_WIDTH - 3 * PIN_SPACE) / 2;
        for (int j = 0; j < 4; j++) {
            UILabel *label = [_pinLabels objectAtIndex:j];
            label.superview.center = CGPointMake(x + j * (PIN_WIDTH + PIN_SPACE) + PIN_WIDTH/2, self.view.frame.size.height / 4);
        }
    }];
}


- (void) wrongPin {
    for (int j = 0; j < 4; j++) {
        UILabel *label = [_pinLabels objectAtIndex:j];
        [self shake:label];
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

- (NSString *) getPinFromFields {
    return _pinField.text;
}

- (void)shake:(UIView*)itemView
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

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)go {
    UserService *service = [[UserService alloc] init];
    NSString *pin = [self getPinFromFields];

    User *user = [service findUserWithPin: pin];
    if (user == nil) {
        [self wrongPin];
        self.numberOfAttempts++;
        if(self.numberOfAttempts == 3) {
            _pinField.enabled = NO;
        }
    }
    else {
        [self didAuthenticate:user];
    }
}

- (void) didAuthenticate: (User *)user {
    [Session setCredentials:[Credentials credentialsWithEmail:nil password:nil pincode:user.pin]];
    self.didAuthenticateBlock( user);
}

@end
