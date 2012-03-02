//
//  ReservationViewController.m
//  HarkPad
//
//  Created by Willem Bison on 02-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationEditViewController.h"
#import "Service.h"

@implementation ReservationEditViewController

@synthesize reservation, languages, datePicker, notesView, nameView, emailView, phoneView, countView, languageView, hostController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        languages = [NSMutableArray arrayWithObjects:@"nl", @"de", @"uk", @"fr", @"it", @"es", nil];
    }
    return self;
}

+ (ReservationEditViewController *) initWithReservation: (Reservation *)reservation
{
    NSString *nib = reservation.type == ReservationTypeWalkin ? @"ReservationWalkinViewController" : @"ReservationViewController";
    ReservationEditViewController *popup = [[ReservationEditViewController alloc] initWithNibName:nib bundle:[NSBundle mainBundle]];
    popup.reservation = reservation;
    return popup;
}

- (void)setReservation:(Reservation *)newReservation
{
    reservation = newReservation;
    notesView.text = reservation.notes;
    nameView.text = reservation.name;
    phoneView.text = reservation.phone;
    emailView.text = reservation.email;
    countView.text = [NSString stringWithFormat:@"%d", reservation.countGuests];
    [self initLanguageView:reservation.language];
    datePicker.date = reservation.startsOn;
}


- (void) initLanguageView: (NSString *)selectedLanguage
{
    [languageView removeAllSegments];
    for(NSUInteger i=0; i < languages.count; i++)
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
    reservation.countGuests = [countView.text intValue];
    reservation.language = [languages objectAtIndex:(NSUInteger) languageView.selectedSegmentIndex];
    
    if(reservation.type == ReservationTypeWalkin) {
    
    }
    else {
        if([nameView.text isEqual:@""])
            return;
        reservation.name = nameView.text;
        reservation.phone = phoneView.text;
        reservation.email = emailView.text;
        reservation.startsOn = datePicker.date;
    }
    
    if(reservation.id == 0)
        [[Service getInstance] createReservation:reservation delegate:hostController callback:@selector(createFetcher:finishedWithData:error:)];
    else
        [[Service getInstance] updateReservation:reservation delegate:hostController callback:@selector(updateFetcher:finishedWithData:error:)];
    
    [hostController closePopup];
}


- (IBAction) cancel
{
    [hostController cancelPopup];    
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
    self.contentSizeForViewInPopover = CGSizeMake(self.view.bounds.size.width + 20, self.view.bounds.size.height);
//    if (reservation.type == Walkin)
//        [countView becomeFirstResponder];
//    else
//        [nameView becomeFirstResponder];
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
