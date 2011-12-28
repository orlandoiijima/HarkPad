//
//  UserListViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UserListViewController.h"
#import "ServiceResult.h"
#import "User.h"
#import "Service.h"
#import "SelectItemDelegate.h"
#import "Utils.h"
#import "ModalAlert.h"

@implementation UserListViewController

@synthesize tableView, users, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (UITableView *)tableView {
    return (UITableView *)self.view;
}

- (NSInteger)tableView:(UITableView *)view numberOfRowsInSection:(NSInteger)section {
    return [users count];
}

- (UITableViewCell *)tableView:(UITableView *)view cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [view dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    User *user = [users objectAtIndex: (NSUInteger)indexPath.row];
    cell.textLabel.text = user.name;

    cell.shouldIndentWhileEditing = NO;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)view {
    return 1;
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.contentSizeForViewInPopover = CGSizeMake(200, 0);

    self.view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 10, 10) style:UITableViewStyleGrouped];

    [[Service getInstance] getUsers:self callback:@selector(getUsersCallback:)];
}

- (void)getUsersCallback: (ServiceResult *)serviceResult {
    users = serviceResult.data;
    if ([users count] == 0) {
        if([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.delegate didSelectItem: [User userNull]];
        }
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    int maxUsers = [users count] > 15 ? 15 : [users count];
    self.contentSizeForViewInPopover = CGSizeMake(200, maxUsers * self.tableView.rowHeight + self.tableView.sectionHeaderHeight + self.tableView.sectionFooterHeight);
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [users objectAtIndex:indexPath.row];
    if (user == nil) return;
    if([self.delegate respondsToSelector:@selector(didSelectItem:)])
        [self.delegate didSelectItem: user];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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
