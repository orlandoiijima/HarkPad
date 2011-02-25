//
//  SlotDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 21-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "SlotDataSource.h"
#import "OrderLine.h"
#import "SlotTable.h"

@implementation SlotDataSource

@synthesize slot;
	
+ (SlotDataSource *) dataSourceForSlot: (Slot *)slot
{
    SlotDataSource *source = [[SlotDataSource alloc] init];
    source.slot = slot;
    return source;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return slot.slotTables.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SlotTable *slotTable = [slot.slotTables objectAtIndex:section];
    return slot == nil ? 0 : slotTable.lines.count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SlotTable *slotTable = [slot.slotTables objectAtIndex:section];
    Table *table = [slotTable.tables objectAtIndex:0];
    return [NSString stringWithFormat:@"Tafel %@", table.name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
    }
    
    SlotTable *slotTable = [slot.slotTables objectAtIndex:indexPath.section];
    OrderLine *line = [slotTable.lines objectAtIndex:indexPath.row];
    cell.textLabel.text = line.product.name;

    NSString *details = line.note;
    for(OrderLinePropertyValue *propertyValue in line.propertyValues)
    {
        details = [NSString stringWithFormat:@"%@ %@", details, propertyValue.displayValue];
    }
    cell.detailTextLabel.text = details;
        
    return cell;
}	

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    SlotTable *slotTable = [slot.slotTables objectAtIndex:indexPath.section];
    OrderLine *line = [slotTable.lines objectAtIndex:indexPath.row];
    cell.backgroundColor = [line.product.category.color colorWithAlphaComponent:0.8];
}
	
@end
