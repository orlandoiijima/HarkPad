//
//  NewLocationViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NewLocationViewController.h"
#import "Service.h"
#import "Session.h"
#import "ItemPropertiesDelegate.h"
#import "Location.h"

@implementation NewLocationViewController
@synthesize popover = _popover;
@synthesize delegate = _delegate;
@synthesize logoLabel = _logoLabel;
@synthesize logoView = _logoView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (IBAction)registerLocation {
    if ([_locationName.text length] == 0) {
        //  TODO
        return;
    }
    Location *location = [[Location alloc] init];
    location.name = _locationName.text;
    if (_logoView.image != nil) {
        location.logo = _logoView.image;
    }
    [[Service getInstance]
            createLocation: location
               credentials: [Session credentials]
                   success: ^(ServiceResult *serviceResult) {
                       [self.delegate didSaveItem:location];
                   }
                     error:^(ServiceResult *result) {
                       [result displayError];
                   }
              progressInfo: [ProgressInfo progressWithActivityText:NSLocalizedString(@"Registering location", nil) label:nil activityIndicatorView:nil]
    ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"New location", <#comment#>);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(registerLocation)];

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
