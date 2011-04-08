//
//  ReservationViewController.m
//  HarkPad
//
//  Created by Willem Bison on 02-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationViewController.h"
#import "Service.h"

@implementation ReservationViewController

@synthesize reservation, languages, datePicker, notesView, nameView, emailView, phoneView, countView, languageView, hostController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        languages = [[NSMutableArray arrayWithObjects:@"nl", @"de", @"fr", @"it", @"es", nil] retain];
    }
    return self;
}

+ (ReservationViewController *) initWithReservation: (Reservation *)reservation
{
    ReservationViewController *popup = [[ReservationViewController alloc] initWithNibName:@"ReservationViewController" bundle:[NSBundle mainBundle]];
    popup.reservation = reservation;
    return popup;
}

- (void)setReservation:(Reservation *)newReservation
{
    [reservation release];
    reservation = [newReservation retain];
    notesView.text = reservation.notes;
    nameView.text = reservation.name;
    phoneView.text = reservation.phone;
    emailView.text = reservation.email;
    countView.selectedSegmentIndex = reservation.countGuests - 2;
    [self initLanguageView:reservation.language];
    datePicker.date = reservation.startsOn;
}


- (void) initLanguageView: (NSString *)selectedLanguage
{
    [languageView removeAllSegments];
    for(int i=0; i < languages.count; i++)
    {
        NSString *language = [languages objectAtIndex:i];
        NSString *imageName = [NSString stringWithFormat:@"%@.png", language]; 
        [languageView insertSegmentWithImage:[UIImage imageNamed:imageName] atIndex: i animated:NO];
        if([language caseInsensitiveCompare:selectedLanguage] == NSOrderedSame) {
            languageView.selectedSegmentIndex = i;
        }
    }
    languageView.selectedSegmentIndex = 0;
    return;
}

- (IBAction) save
{
    reservation.notes = notesView.text;
    reservation.name = nameView.text;
    reservation.phone = phoneView.text;
    reservation.email = emailView.text;
    reservation.countGuests = countView.selectedSegmentIndex + 2;
    reservation.startsOn = datePicker.date;
    reservation.language = [languages objectAtIndex: languageView.selectedSegmentIndex];
    
    if([reservation.name isEqual:@""] || reservation.name == nil)
        return;
    if(reservation.id == 0)
        [[Service getInstance] createReservation:reservation];
    else
        [[Service getInstance] updateReservation:reservation];
    [hostController closePopup];
}

- (IBAction) cancel
{
    [hostController cancelPopup];    
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = self.view.bounds.size;
    datePicker.minimumDate = [NSDate date];
    [self setReservation:reservation];
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
	return YES;
}

@end
