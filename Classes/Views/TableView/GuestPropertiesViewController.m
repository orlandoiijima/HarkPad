//
//  GuestPropertiesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 02/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GuestPropertiesViewController.h"
#import "ToggleButton.h"
#import "GuestProperties.h"


@implementation GuestPropertiesViewController

@synthesize guest = _guest, delegate;

+ (GuestPropertiesViewController *) controllerWithGuest: (Guest *)guest {
    GuestPropertiesViewController *controller = [[GuestPropertiesViewController alloc] init];
    controller.title = NSLocalizedString(@"Guests", nil);
    controller.tabBarItem.image = [UIImage imageNamed:@"group.png"];
    controller.guest = guest;
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

- (void)setGuest: (Guest *) newGuest
{
    _guest = newGuest;
    ((GuestProperties *)self.view).guest = newGuest;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) tapDiet:(id) sender
{
    ToggleButton *toggleButton = (ToggleButton *)sender;
    if (toggleButton == nil) return;
    if (toggleButton.isOn)
        _guest.diet |= toggleButton.tag;
    else
        _guest.diet &= ~toggleButton.tag;

    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
        [self.delegate didModifyItem:_guest];
}

- (void) tapGender: (id)sender {
    ToggleButton *seatView = (ToggleButton *)sender;
    if (seatView == nil) return;
    GuestProperties *propView = (GuestProperties *)self.view;
    propView.viewMale.isOn = seatView == propView.viewMale;
    propView.viewFemale.isOn = seatView == propView.viewFemale;
    propView.viewEmpty.isOn = seatView == propView.viewEmpty;
    _guest.isMale = propView.viewMale.isOn;
    _guest.isEmpty = propView.viewEmpty.isOn;

    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
        [self.delegate didModifyItem: _guest];
}

- (void) tapHost: (id)sender {
    ToggleButton *isHostView = (ToggleButton *)sender;
    _guest.isHost = isHostView.isOn;

    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
        [self.delegate didModifyItem: _guest];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView
//{
//    self.view = [GuestProperties viewWithGuest:guest frame: CGRectZero delegate: self];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view = [GuestProperties viewWithGuest:_guest frame: self.view.bounds delegate: self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
