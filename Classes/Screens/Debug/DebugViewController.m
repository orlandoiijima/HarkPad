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
    [AppVault setLocationName:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 4;
        case 2:
            return 5;
        case 3:
            return [[Logger lines] count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"App";
        case 1:
            return @"Vault";
        case 2:
            return @"Session";
        case 3:
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
                case 0: {
                    cell.textLabel.text = @"Versie";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                    [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"],
                                    [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"]];
                    break;
                }
                case 1: {
                    cell.textLabel.text = @"Datum";
                    cell.detailTextLabel.text = [self getSettingValueForKey:@"BuildDate"];
                    break;
                }
                case 2: {
                    cell.textLabel.text = @"Gemaakt door";
                    cell.detailTextLabel.text = @"The Attic";
                    break;
                }
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Account";
                    cell.detailTextLabel.text = [AppVault accountId];
                    break;
                case 1:
                    cell.textLabel.text = @"Location";
                    cell.detailTextLabel.text = [AppVault locationId];
                    break;
                case 2:
                    cell.textLabel.text = @"Device";
                    cell.detailTextLabel.text = [AppVault deviceId];
                    break;
                case 3:
                    cell.textLabel.text = @"Location name";
                    cell.detailTextLabel.text = [AppVault locationName];
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Name";
                    cell.detailTextLabel.text = [[Session authenticatedUser] name];
                    break;
                case 1: {
                    cell.textLabel.text = @"Role";
                    int role = [[Session authenticatedUser] role];
                    id roles = @[@"Standard", @"Manager", @"Backoffice", @"Administrator"];
                    cell.detailTextLabel.text = role < 4 ? roles[role] : @"Error";
                    break;
                }
                case 2:
                    cell.textLabel.text = @"Pin";
                    cell.detailTextLabel.text = [[[Session credentials] pinCode] length] ? @"****" : @"(unknown)";
                    break;
                case 3:
                    cell.textLabel.text = @"Password";
                    cell.detailTextLabel.text = [[[Session credentials] password] length] ? @"*******" : @"(unknown)";
                    break;
                case 4:
                    cell.textLabel.text = @"Email";
                    cell.detailTextLabel.text = [[Session credentials] email] == nil ? @"(unknown)":[[Session credentials] email];
                    break;
            }
            break;
        case 3: {
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

- (NSString *) getSettingValueForKey:(NSString *)keyToGet {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if([key isEqualToString: keyToGet]) {
            return [prefSpecification objectForKey:@"DefaultValue"];
        }
    }
    return @"";
}

@end
