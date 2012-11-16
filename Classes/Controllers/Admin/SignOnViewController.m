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
#import "EditUserViewController.h"

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self  action:@selector(done)];

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
      [[_logoView layer] addSublayer:shapeLayer];

    [_organisation becomeFirstResponder];
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
    return YES;
}

- (IBAction)done {
    if ([self validate] == NO)
        return;
    Signon *signOn = [[Signon alloc] init];
    signOn.name = _organisation.text;
    if (_isLogoSet) {
        signOn.logo = _logoView.image;
    }

    EditUserViewController *controller = [[EditUserViewController alloc] init];
    controller.signOn = signOn;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _isLogoSet = YES;
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
