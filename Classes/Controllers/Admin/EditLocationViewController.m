//
//  EditLocationViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EditLocationViewController.h"

@implementation EditLocationViewController
@synthesize popover = _popover;
@synthesize delegate = _delegate;
@synthesize logoLabel = _logoLabel;
@synthesize logoView = _logoView;
@synthesize location = _location;

+ (EditLocationViewController *)controllerWithLocation:(Location *)location delegate: (id<ItemPropertiesDelegate>) delegate {
    EditLocationViewController * controller = [[EditLocationViewController alloc] init];
    controller.location = location;
    controller.delegate = delegate;
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

- (IBAction)done {
    if ([_locationName.text length] == 0) {
        //  TODO
        return;
    }

    _location.name = _locationName.text;
    if (_logoView.image != nil) {
        _location.logo = _logoView.image;
    }

    Service *service = [Service getInstance];
    HttpVerb verb = _location.isNew ? HttpVerbPost : HttpVerbPut;
    [service requestResource:@"location" id:nil action:nil arguments:nil body:[_location toDictionary] verb:verb success:^(ServiceResult *serviceResult) {
        [self.delegate didSaveItem:_location];
    }                  error:^(ServiceResult *result) {
        [result displayError];
    }           progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Storing location", nil) parentView:self.view]];

}

- (BOOL)requiresAdmin {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _location.isNew ?  NSLocalizedString(@"New location", <#comment#>) :  NSLocalizedString(@"Edit location", <#comment#>);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

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

    _logoView.image = _location.logo;
    _locationName.text = _location.name;
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
