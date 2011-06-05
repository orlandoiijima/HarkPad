//
//  TablesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 22-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "TablesViewController.h"
#import "Cache.h"
#import "District.h"
#import "Service.h"
#import "TableMapViewController.h"

@implementation TablesViewController

@synthesize groupedTables, tablesInfo, selectionMode, tableView, popoverController, orderId;

- (id)initWithTables:(NSMutableArray *)tables
{
    self = [super init];
    if (self) {
        [self createDataSource: tables];
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

    if(groupedTables == nil)
        [[Service getInstance] getTablesInfoForDistrict:-1 delegate: self callback:@selector(createDataSource:)];
    self.contentSizeForViewInPopover = CGSizeMake(170, 500);
}

- (void) createDataSource: (NSMutableArray *)tables
{
    self.tablesInfo = tables;
    self.groupedTables = [[NSMutableDictionary alloc] init];
    for(TableInfo *tableInfo in tables)
    {
        if(selectionMode == selectEmpty && tableInfo.isEmpty == false)
            continue;
        if(selectionMode == selectFilled && tableInfo.isEmpty)
            continue;
        if(tableInfo.table.dockedToTableId != -1)
            continue;
        District *district = [[[Cache getInstance] map] getDistrict:tableInfo.table.id];
        
        NSMutableArray *group = [groupedTables objectForKey:district.name];
        if(group == nil)
        {
            group = [[NSMutableArray alloc] init];
            [groupedTables setObject:group forKey: district.name]; 
        }
        [group addObject:tableInfo];
    }
    for(NSMutableArray *key in [groupedTables allKeys])
        [groupedTables setObject: [[groupedTables objectForKey:key] sortedArrayUsingSelector:@selector(compare:)] forKey:key];
    [self.tableView reloadData];
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
    if(groupedTables == nil) return 0;
    return [groupedTables count];
}

- (NSString *) keyForSection:(int) section
{
    NSArray* sortedKeys = [[groupedTables allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

- (NSMutableArray *) groupForSection:(int) section
{
    NSString *key = [self keyForSection:section];
    return [groupedTables objectForKey:key];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tables = [self groupForSection:section];
    return [tables count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(groupedTables == nil || section >= [groupedTables count]) return @"";
    return [NSString stringWithFormat:@"Wijk %@", [self keyForSection:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(groupedTables == nil || indexPath.section >= [groupedTables count]) return 0;
    NSMutableArray *tables = [self groupForSection:indexPath.section];
    if(indexPath.row >= [tables count]) return cell;
    
    TableInfo *tableInfo = [tables objectAtIndex:indexPath.row];
    cell.textLabel.text = tableInfo.table.name;
    if(tableInfo.isEmpty == false) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d gasten", [tableInfo.orderInfo.seats count]];
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d stoelen", tableInfo.table.countSeats];
    }
    return cell;
}

- (IBAction) done
{
    [popoverController dismissPopoverAnimated:YES];

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSMutableArray *tables = [self groupForSection:indexPath.section];
    TableInfo *tableInfo = [tables objectAtIndex:indexPath.row];

    TableMapViewController *tableMapViewController = (TableMapViewController*) popoverController.delegate;
    [tableMapViewController transferOrder: orderId toTable: tableInfo.table.id];
}

- (IBAction) cancel
{
    [popoverController dismissPopoverAnimated:YES];
}

@end
