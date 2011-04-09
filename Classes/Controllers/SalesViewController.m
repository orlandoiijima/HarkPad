//
//  SalesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "SalesViewController.h"
#import "Service.h"
#import "ProductTotals.h"

@implementation SalesViewController

@synthesize groupedTotals, dateToShow, dateLabel, tableAmounts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [groupedTotals count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self keyForSection:section];
    return [[groupedTotals objectForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self keyForSection:section];
}

- (NSString *) keyForSection: (int) section
{
    if(section > [groupedTotals count])
        return @"";
    NSArray* sortedKeys = [[groupedTotals allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

    NSString *key = [self keyForSection:indexPath.section];
    ProductTotals *totals = [[groupedTotals objectForKey:key] objectAtIndex:indexPath.row];
    cell.backgroundColor = totals.product.category.color;
    cell.textLabel.text = totals.product.name;

    return cell;
}

- (void) refreshView
{
    dateLabel.text = [dateToShow prettyDateString];

    // Do any additional setup after loading the view from its nib.
    NSMutableArray *productTotals = [[Service getInstance] getSalesStatistics:dateToShow];
    
    groupedTotals = [[NSMutableDictionary alloc] init];
    for(ProductTotals *total in productTotals) {
        NSString *key = [NSString stringWithFormat:@"%d %@", total.product.category.sortOrder, total.product.category.name];
        NSMutableArray *totals = [groupedTotals objectForKey:key];
        if(totals == nil)
        {
            totals = [[NSMutableArray alloc] init];
            [groupedTotals setObject: totals forKey:key];
        }
        [totals addObject:total];
    }
    [tableAmounts reloadData];
}

- (IBAction)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    int interval = sender.direction == UISwipeGestureRecognizerDirectionLeft ? 24*60*60 : -24*60*60;
    dateToShow = [[dateToShow dateByAddingTimeInterval: interval] retain]; 
    [self refreshView];
}

- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    dateToShow = [[NSDate date] retain]; 
    [self refreshView];
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
    
    dateToShow = [[NSDate date] retain];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];   
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];   
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];   
    
    [self refreshView];
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
