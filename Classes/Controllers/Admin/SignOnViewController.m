//
//  SignOnViewController.m
//  HarkPad
//
//  Created by Willem Bison on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
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

    [_logoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectLogo:)]];
      CAShapeLayer *shapeLayer = [CAShapeLayer layer];
      shapeLayer.frame = CGRectInset(_logoView.bounds, -10, -10);
      [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
      [shapeLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
      [shapeLayer setLineWidth:1.0f];
      [shapeLayer setLineJoin:kCALineJoinRound];
      [shapeLayer setLineDashPattern:
       [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
        [NSNumber numberWithInt:5],
        nil]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeLayer.bounds cornerRadius:15.0];
      [shapeLayer setPath:path.CGPath];
      [[_logoView layer] addSublayer:shapeLayer];}

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
    signOn.name = _organisation.text;
    signOn.firstName = _firstName.text;
    signOn.surName = _surName.text;
    signOn.pinCode = _pincode.text;
    signOn.email = _email.text;
    signOn.password = _password.text;
    if (_logoView.image != nil) {
        signOn.logo = _logoView.image;
    }

    [[Service getInstance]
            signon:signOn
           success: ^(ServiceResult *result) {
               [AppVault setDeviceId: [result.jsonData valueForKey:@"deviceId"]];
               [AppVault setAccountId: [result.jsonData valueForKey:@"accountId"]];
               [AppVault setLocationId: [result.jsonData valueForKey:@"locationId"]];
               [AppVault setLocationName: [result.jsonData valueForKey:@"locationName"]];
           }
             error:^(ServiceResult *serviceResult) {
                        [serviceResult displayError];
                    }
    ];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _logoView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_popover dismissPopoverAnimated:YES];

}

- (IBAction)selectLogo: (id)dummy {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    controller.delegate = self;
    _popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    _popover.delegate = self;
    [_popover presentPopoverFromRect:_logoView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
