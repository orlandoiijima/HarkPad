//
//  TablePopupMenu.m
//  HarkPad2
//
//  Created by Willem Bison on 30-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TablePopupMenu.h"
#import "OrderLineCell.h"
#import "TableMapViewController.h"
#import "Service.h"
#import "Utils.h"

@implementation TablePopupMenu

@synthesize table, order, popoverController, infoItems, tableInfoView, commandItems;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

+ (TablePopupMenu *) menuForTable: (Table *) table withOrder: (Order *) order
{
    TablePopupMenu *tablePopupMenu = [[TablePopupMenu alloc] initWithStyle:UITableViewStyleGrouped];
    tablePopupMenu.table = table;
    tablePopupMenu.order = order;
    tablePopupMenu.tableInfoView = [TableInfoView viewWithOrder:order];
    return tablePopupMenu;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    infoItems = [[NSMutableDictionary alloc] init];
    [infoItems setValue:[NSString stringWithFormat:@"%d", [order getLastSeat]+1] forKey: @"Aantal personen"];
    [infoItems setValue:[NSString stringWithFormat:@"%d", [order getLastCourse]+1] forKey: @"Aantal gangen"];
    [infoItems setValue:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[order getFirstOrderDate]]] forKey: @"Eerste bestelling"];
    [infoItems setValue:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[order getLastOrderDate]]] forKey: @"Laatste bestelling"];
    int currentCourse = [order getCurrentCourse];
    NSString *lastCourse = currentCourse == -1 ? @"-" : [Utils getCourseChar: currentCourse];
    [infoItems setValue:[NSString stringWithFormat:@"%@", lastCourse] forKey: @"Laatst opgevraagde gang"];

    commandItems = [[NSMutableDictionary alloc] init];
    [commandItems setValue:@"Bestelling opnemen" forKey: @"Bestelling"];
    if(order != nil)
    {
        if([order getCurrentCourse] == [order getLastCourse])
            [commandItems setValue:@"Rekening opmaken" forKey: @"Rekening	"];
        else
        {
//            int nextCourse = [order getCurrentCourse]+1;
//            NSString command = [NSString stringWithFormat: @"Gang %@ opvragen", [Utils getCourseChar: nextCourse]];
//            
//            [commandItems setValue:command forKey: @"Gang"];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(order == nil)
        return 1;
    else
        return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section)
    {
        case 1:
            return infoItems.count;
        case 0:
            if(order == nil)
                return 1;
            else
                return 2;
//            {
//                if([order getCurrentCourse] == [order getLastCourse])
//                    return 2;
//                else
//                    return 3;
//            }
        case 2:
            return order.lines.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section)
    {
        case 0:
            return [NSString stringWithFormat:@"Tafel %@", table.name];
            break;
        case 1:
            return @"Info";
        case 2:
            if(order == nil) return @"";
            return [NSString stringWithFormat:@"Totaal bedrag %0.2f", [[order getAmount] floatValue]];
            break;
    }
    return @"";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    switch(indexPath.section)
    {
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.textLabel.text = [[infoItems allKeys] objectAtIndex: indexPath.row];
            cell.detailTextLabel.text = [[infoItems allValues] objectAtIndex: indexPath.row];
            return cell;
        }
            
        case 0:
        {            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            switch(indexPath.row)
            {
                case 0: cell.textLabel.text = @"Bestelling opnemen"; break;
                case 1:
                {
                    if([order getCurrentCourse] == [order getLastCourse])
                    {
                        cell.textLabel.text = @"Rekening opmaken";
                    }
                    else
                    {
                        int nextCourse = [order getCurrentCourse]+1;
                        cell.textLabel.text = [NSString stringWithFormat: @"Gang %@ opvragen", [Utils getCourseChar: nextCourse]];
                    }
                    break;
                }
            }
            return cell;
            break;
        }
          
        case 2:
        {
            OrderLineCell *cell = (OrderLineCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderLineCell" owner:self options:nil] lastObject];
            }
            OrderLine *line = [order.lines objectAtIndex:indexPath.row];
            cell.orderLine = line;
            return cell;
        }
    }
    return nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != 0) return;
    switch(indexPath.row)
    {
        case 0:
        {
            TableMapViewController *tableMapController = (TableMapViewController*) popoverController.delegate;
            if(order == nil)
                [tableMapController newOrderForTable: table];
            else
                [tableMapController editOrder:order];
            [popoverController dismissPopoverAnimated:YES];
            break;
        }
        case 1:
        {
            if([order getCurrentCourse] == [order getLastCourse])
            {
                [[Service getInstance] makeBills:nil forOrder: order.id]; 
                [popoverController dismissPopoverAnimated:YES];
            }
            else
            {
                int nextCourse = [order getCurrentCourse] + 1;
                [[Service getInstance] startCourse: nextCourse forOrder: order.id]; 
                [popoverController dismissPopoverAnimated:YES];
            }
        }
    }
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

