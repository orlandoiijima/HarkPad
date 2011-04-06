//
//  LogViewController.m
//  HarkPad
//
//  Created by Willem Bison on 03-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "LogViewController.h"
#import "Service.h"
#import "SettingsViewController.h"

@implementation LogViewController

@synthesize logTableView, logLines, detailLabel, captionButton, settingsButton;

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
    NSMutableArray *group = [logLines objectForKey: [[logLines allKeys] objectAtIndex:indexPath.section]];
    NSString *line = [group objectAtIndex:indexPath.row];
    if(line != nil)
    {
        detailLabel.text = line;
    }
}

- (void)dealloc
{
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

- (IBAction) settings
{
    SettingsViewController *popup = [[SettingsViewController alloc] init];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController: popup];
    popover.delegate = self;
    
    [popover presentPopoverFromRect:CGRectMake(0,0,10,10) inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refresh];
    
    captionButton.title = [NSString stringWithFormat:@"Log %@", [[Service getInstance] url]];
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
