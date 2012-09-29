//
//  NewLocationViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import "NewLocationViewController.h"
#import "Service.h"
#import "CredentialsAlertView.h"

@implementation NewLocationViewController
@synthesize popover = _popover;


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
//    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)selectLogo {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    controller.delegate = self;
    _popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    _popover.delegate = self;
    [_popover presentPopoverFromRect:_logoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)registerLocation {
    [CredentialsAlertView
        viewWithPincode: @"1234"
        afterDone: ^(Credentials *credentials)
            {
                [[Service getInstance]
                        createLocation: _locationName.text
                           credentials: credentials
                               success:nil
                               error:^(ServiceResult *result) {
                                   [result displayError];
                               }
                ];
                return;
            }
    ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
