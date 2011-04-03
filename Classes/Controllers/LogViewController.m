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

@synthesize logTableView, logLines;

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *group = [logLines objectForKey: [[logLines allKeys] objectAtIndex:section]];
    return [group count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[logLines allKeys] objectAtIndex:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSMutableArray *group = [logLines objectForKey: [[logLines allKeys] objectAtIndex:indexPath.section]];
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
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 22;
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

- (IBAction) refresh
{
    NSMutableArray *lines = [[[Service getInstance] getLog] retain];
    logLines = [[NSMutableDictionary alloc] init];
    for(NSString *line in lines)
    {
        NSString *dateKey = [line substringToIndex:10];
        NSMutableArray *group = [logLines objectForKey:dateKey];
        if(group == nil)
        {
            group = [[NSMutableArray alloc] init];
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
