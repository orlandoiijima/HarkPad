//
//  ChefViewController.m
//  HarkPad
//
//  Created by Willem Bison on 20-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ChefViewController.h"
#import "KitchenStatistics.h"
#import "Service.h"

@implementation ChefViewController

@synthesize firstSlotDataSource, secondSlotDataSource, firstTable, secondTable, clockLabel, slots, startNextSlotButton;
@synthesize totalDoneLabel, totalInProgressLabel, totalInSlotLabel, totalNotYetRequestedLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(updateClock)
                                   userInfo:nil
                                    repeats:YES];    
 
    [self updateClock];
    [self refreshView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) refreshView
{
    slots = [[Service getInstance] getCurrentSlots];
    if(slots != nil && slots.count > 0)
    {
        firstTable.dataSource = [SlotDataSource dataSourceForSlot: [slots objectAtIndex:0]];
        firstTable.delegate = firstTable.dataSource;
        if(slots.count > 1) {
            secondTable.dataSource = [SlotDataSource dataSourceForSlot: [slots objectAtIndex:1]];
            secondTable.delegate = secondTable.dataSource;
        }
        else
            secondTable.dataSource = nil;
            
        [firstTable reloadData];
        [secondTable reloadData];
    }
    else
        firstTable.dataSource = nil;
    
    KitchenStatistics *stats = [[Service getInstance] getKitchenStatistics];
    totalDoneLabel.text = [NSString stringWithFormat: @"%d", stats.done];
    totalInProgressLabel.text = [NSString stringWithFormat: @"%d", stats.inProgress];
    totalInSlotLabel.text = [NSString stringWithFormat: @"%d", stats.inSlot];
    totalNotYetRequestedLabel.text = [NSString stringWithFormat: @"%d", stats.notYetRequested];
    
}

- (void) updateClock
{
    if(slots == nil) return;
    if(slots.count == 0) return;
    Slot *slot = [slots objectAtIndex:0];
    int interval = -1 * (int)[slot.startedOn timeIntervalSinceNow];
    clockLabel.text = [NSString stringWithFormat:@"%0d:%02d", interval / 60, interval % 60]; 
}

- (IBAction) startNextSlot
{
    [[Service getInstance] startNextSlot];   
    [self refreshView];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
