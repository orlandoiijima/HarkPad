//
//  EditCompanyViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EditCompanyViewController.h"
#import "Company.h"
#import "Address.h"

@implementation EditCompanyViewController

@synthesize popover = _popover;
@synthesize delegate = _delegate;
@synthesize logoLabel = _logoLabel;
@synthesize logoView = _logoView;
@synthesize streetField = _streetField;
@synthesize numberField = _numberField;
@synthesize zipCodeField = _zipCodeField;
@synthesize cityField = _cityField;
@synthesize phoneField = _phoneField;


+ (EditCompanyViewController *)controllerWithCompany:(Company *)company delegate: (id<ItemPropertiesDelegate>) delegate {
    EditCompanyViewController * controller = [[EditCompanyViewController alloc] init];
    controller.company = company;
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
    if ([_companyName.text length] == 0) {
        //  TODO
        return;
    }
    _company.name = _companyName.text;

    _company.address.street = _streetField.text;
    _company.address.number = _numberField.text;
    _company.address.zipCode = _zipCodeField.text;
    _company.address.city = _cityField.text;
    _company.phone = _phoneField.text;
            
    if (_logoView.image != nil) {
        _company.logo = _logoView.image;
    }

    Service *service = [Service getInstance];
    HttpVerb verb = _company.isNew ? HttpVerbPost : HttpVerbPut;
    [service requestResource:@"company" id:nil action:nil arguments:nil body:[_company toDictionary] verb:verb success:^(ServiceResult *serviceResult) {
        [self.delegate didSaveItem:_company];
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
    self.title = _company.isNew ?  NSLocalizedString(@"New company", <#comment#>) :  NSLocalizedString(@"Edit company", <#comment#>);

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

    _logoView.image = _company.logo;
    _companyName.text = _company.name;
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
