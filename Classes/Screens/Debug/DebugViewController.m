//
//  DebugViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DebugViewController.h"
#import "AppVault.h"
#import "ModalAlert.h"
#import "Logger.h"
#import "LogItem.h"
#import "Session.h"

@interface DebugViewController ()

@end

@implementation DebugViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Debug";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearVault)];
}

- (void)clearVault {
    if([ModalAlert confirm:@"Unregister device ?"] == NO)
        return;
    [AppVault setDeviceId:nil];
    [AppVault setAccountId:nil];
    [AppVault setLocationId:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 5;
        case 1:
            return 4;
        case 2:
            return [[Logger lines] count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Vault";
        case 1:
            return @"Session";
        case 2:
            return @"Log";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Versie";
                    cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
                    break;
                case 1:
                    cell.textLabel.text = @"Account";
                    cell.detailTextLabel.text = [AppVault accountId];
                    break;
                case 2:
                    cell.textLabel.text = @"Location";
                    cell.detailTextLabel.text = [AppVault locationId];
                    break;
                case 3:
                    cell.textLabel.text = @"Device";
                    cell.detailTextLabel.text = [AppVault deviceId];
                    break;
                case 4:
                    cell.textLabel.text = @"Location name";
                    cell.detailTextLabel.text = [AppVault locationName];
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Name";
                    cell.detailTextLabel.text = [[Session authenticatedUser] name];
                    break;
                case 1:
                    cell.textLabel.text = @"Pin";
                    cell.detailTextLabel.text = [[[Session credentials] pinCode] length] ? @"***" : @"";
                    break;
                case 2:
                    cell.textLabel.text = @"Password";
                    cell.detailTextLabel.text = [[[Session credentials] password] length] ? @"***" : @"";
                    break;
                case 3:
                    cell.textLabel.text = @"Email";
                    cell.detailTextLabel.text = [[Session credentials] email] == nil ? @"":[[Session credentials] email];
                    break;
            }
            break;
        case 2: {
            int index = (int)[[Logger lines] count] - indexPath.row - 1;
            if (index >= 0) {
                LogItem *logItem = [[Logger lines] objectAtIndex:index];
                cell.textLabel.text = logItem.message;
            }
            break;
        }
    }

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
