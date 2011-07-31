//
//  LogViewController.m
//  HarkPad
//
//  Created by Willem Bison on 03-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "LogViewController.h"
#import "Service.h"

@implementation LogViewController

@synthesize logTableView, logLines, detailLabel, captionButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [logLines count];
}

- (NSString *) keyForSection: (int)section
{
    NSArray* sortedKeys = [[logLines allKeys] sortedArrayUsingSelector:@selector(compare:)];
    section = [sortedKeys count] - 1 - section;
    return [sortedKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self keyForSection:section];
    NSMutableArray *group = [logLines objectForKey: key];
    return [group count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self keyForSection:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *key = [self keyForSection:indexPath.section];
    NSMutableArray *group = [logLines objectForKey: key];
    NSString *line = [group objectAtIndex:indexPath.row];
    if(line != nil)
    {
        NSString *type = [line substringWithRange: NSMakeRange(26,4)];
        if([type isEqualToString:@"INFO"] == false)
            cell.detailTextLabel.textColor = [UIColor redColor];
        else
            cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [line substringFromIndex:35];
        cell.textLabel.text = [line substringWithRange: NSMakeRange(11,8)];
        cell.contentView.backgroundColor = indexPath.row & 1 ? [UIColor colorWithRed:0.85 green:0.85 blue:0.8 alpha:1] : [UIColor whiteColor];
        cell.textLabel.backgroundColor = cell.detailTextLabel.backgroundColor = cell.contentView.backgroundColor;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 22;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self keyForSection:indexPath.section];
    NSMutableArray *group = [logLines objectForKey: key];
    NSString *line = [group objectAtIndex:indexPath.row];
    if(line != nil)
    {
        detailLabel.text = line;
    }
}

- (void)dealloc
{
    [logTableView release];
    [logLines release];
    [detailLabel release];
    [captionButton release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (IBAction) refresh
{
    NSMutableArray *lines = [[Service getInstance] getLog];
    self.logLines = [[[NSMutableDictionary alloc] init] autorelease];
    for(NSString *line in lines)
    {
        if([line length] < 10) continue;
        NSString *dateKey = [line substringToIndex:10];
        NSMutableArray *group = [logLines objectForKey:dateKey];
        if(group == nil)
        {
            group = [[[NSMutableArray alloc] init] autorelease];
            [logLines setValue:group forKey:dateKey];
        }
        [group insertObject:line atIndex:0];
    }
    [logTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refresh];
    
    NSString *env = [[NSUserDefaults standardUserDefaults] stringForKey:@"env"];
    
    captionButton.title = [NSString stringWithFormat:@"Log %@ [%@]", [[Service getInstance] url], env];
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
