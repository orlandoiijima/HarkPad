//
//  DashboardViewController.m
//  HarkPad
//
//  Created by Willem Bison on 04-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "DashboardViewController.h"
#import "Service.h"
#import "Utils.h"

@implementation DashboardViewController

@synthesize data, lastUpdate, labels, sections, images;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) didDataReceiveCallback: (ServiceResult *)result
{
    self.data = result.jsonData;
    [super dataSourceDidFinishLoadingNewData]; 
    self.lastUpdate = [NSDate date];
    [self.tableView reloadData];
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
    self.sections = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 [NSArray arrayWithObjects:@"salesFood", @"salesDrink", nil], @"Omzet",
                 [NSArray arrayWithObjects:@"countGuestsNow", @"countGuestsToday", nil], @"Gasten",
                 [NSArray arrayWithObjects:@"countReservations", @"countReservationsNextDay", nil], @"Reserveringen",
                 nil];
    self.images = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 [UIImage imageNamed:@"creditcard.png"], @"Omzet",
                 [UIImage imageNamed:@"group.png"], @"Gasten",
                 [UIImage imageNamed:@"calendar.png"], @"Reserveringen",
                 nil];
    self.labels = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            NSLocalizedString(@"Food", nil), @"salesFood",
            NSLocalizedString(@"Drink", nil), @"salesDrink",
            NSLocalizedString(@"Now", nil), @"countGuestsNow",
            NSLocalizedString(@"Today", nil), @"countGuestsToday",
            NSLocalizedString(@"Today", nil), @"countReservations",
            NSLocalizedString(@"Tomorrow", nil), @"countReservationsNextDay",
        nil];
    
    self.lastUpdate = nil;
    [self reloadTableViewDataSource];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionKey = [[self.sections allKeys] objectAtIndex:section];
    return [[self.sections objectForKey:sectionKey] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection: (NSInteger)section
{
    NSString *key = [[self.sections allKeys] objectAtIndex:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self.images objectForKey:key]];
    imageView.frame = CGRectMake(20, 5, imageView.image.size.width, 20);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.bounds.size.width + 5, 5, 200, 20)];
    label.text = key;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor colorWithWhite:0.08 alpha:1];
    label.shadowColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:imageView];
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    NSString *sectionKey = [[self.sections allKeys] objectAtIndex:indexPath.section];
    NSArray *items = [self.sections objectForKey:sectionKey];
    NSString *key = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = [labels objectForKey:key];
    id value = [data objectForKey:key];
    if([key hasPrefix: @"sales"] && [value isKindOfClass:[NSNumber class]] )
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [Utils getAmountString:value withCurrency:YES]];
    else
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value == nil ? @"" : value];
    return cell;
}

- (void) reloadTableViewDataSource
{
    [[Service getInstance] getDashboardStatistics:self callback:@selector(didDataReceiveCallback:)];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.sections allKeys] objectAtIndex:section];
}


@end
