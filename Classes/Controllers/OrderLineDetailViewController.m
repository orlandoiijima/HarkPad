//
//  OrderLineDetailViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderLineDetailViewController.h"
#import "OrderLinePropertyValue.h"
#import "PropertyOptionViewController.h"

@implementation OrderLineDetailViewController

@synthesize orderLine, popoverContainer, noteTextField, controller;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    if(orderLine != nil)
        self.title = orderLine.product.key;
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Add the "done" button to the navigation bar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    
    self.navigationItem.leftBarButtonItem = doneButton;
    [doneButton release];
  }

//  Resize popover to size of table
- (void) viewDidAppear: (BOOL) animate {
    [super viewDidAppear:animate];
//    self.contentSizeForViewInPopover = [[self tableView] contentSize];
}

- (void) doneAction {
    if(popoverContainer != nil)
    {
        orderLine.note = noteTextField.text;
        for(OrderLineProperty *property in orderLine.product.properties)
        {
            if(property.options.count <= 1)
            {
                UISwitch *sw = (UISwitch*) [self.view viewWithTag:property.id];
                if(sw != nil)
                    [orderLine setStringValueForProperty:property value: sw.on ? @"Y" : @"N"];
            }
        }
        orderLine.entityState = Modified;
        [popoverContainer dismissPopoverAnimated:YES];
        [controller refreshSelectedCell];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if(orderLine.product.properties.count > 0) return 2;
    else return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(orderLine.product.properties.count > 0)
    {
        if(section == 0) return orderLine.product.properties.count; 
        return 1;
    }
    else return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0 && orderLine.product.properties.count > 0)
        return @"Extra";
    else
        return @"Notitie";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(indexPath.section == 0 && orderLine.product.properties.count > 0)
    {
        // Configure the cell...
        OrderLineProperty *property = [orderLine.product.properties objectAtIndex:indexPath.row];
        cell.textLabel.text = property.name;
        NSString *propertyValue = [orderLine getStringValueForProperty:property];
        if(property.options.count > 1)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if(propertyValue != nil)
                cell.detailTextLabel.text = propertyValue;
        }
        else
        {
            UISwitch *sw = [[UISwitch alloc] init];
            sw.tag = property.id;
            cell.accessoryView = sw;
            if([propertyValue compare:@"Y"] == NSOrderedSame)
                sw.on = YES;
        }
        return cell;
    }
    else
    {
        CGRect rect = CGRectMake(0, 0,cell.bounds.size.width, cell.bounds.size.height);
        rect = CGRectInset(rect, 17, 10);
        noteTextField = [[UITextField alloc] initWithFrame:rect];
        noteTextField.text = orderLine.note;
        [cell addSubview: noteTextField];
        return cell;
        
    }        
}


#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= orderLine.product.properties.count) return;
    OrderLineProperty *property = [orderLine.product.properties objectAtIndex:indexPath.row];
    if(property.options.count < 1)
        return;
	PropertyOptionViewController *propertyViewController = [[PropertyOptionViewController alloc] init];
    NSString *option = [orderLine getStringValueForProperty:property];
    [orderLine setStringValueForProperty:property value: option];
    propertyViewController.orderLinePropertyValue = [orderLine getValueForProperty:property];
    // Pass the selected object to the new view controller.
	[self.navigationController pushViewController:propertyViewController animated:YES];
	[propertyViewController release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

