	//
//  InvoiceDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "OrderDataSource.h"
#import "Order.h"
#import "OrderLineCell.h"
#import "Service.h"
#import "ModalAlert.h"
#import "Utils.h"

@implementation OrderDataSource

@synthesize totalizeProducts, showFreeProducts, order, groupedLines, grouping, invoicesViewController, showProductProperties, isEditable, delegate = _delegate, rowHeight, sortOrder, showPrice;

+ (OrderDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping totalizeProducts: (bool) totalize showFreeProducts: (bool)showFree showProductProperties: (bool)showProps isEditable: (bool) isEditable showPrice: (bool)showPrice
{
    OrderDataSource *source = [[OrderDataSource alloc] init];
    source.totalizeProducts = totalize;
    source.showFreeProducts = showFree;
    source.showProductProperties = showProps;
    source.showPrice = showPrice;
    source.order = order;
    source.grouping = grouping;
    source.isEditable = isEditable;
    source.rowHeight = 44;
    source.sortOrder = sortByCategory;
    return source;
}

- (void) setDelegate: (id) newDelegate {
    _delegate = newDelegate;
}

- (void) setGrouping: (OrderGrouping) newGrouping
{
    if (order == nil) return;
    grouping = 	newGrouping;
    self.groupedLines = [[NSMutableDictionary alloc] init];
    for(OrderLine *line in order.lines)
    {
        [self tableView:nil addLine:line];
    }
    return;
}

- (void) tableView:(UITableView *)tableView addLine: (OrderLine *)line {
    if([line.product.price isEqualToNumber: [NSDecimalNumber zero]] && showFreeProducts == false)
        return;
    NSString *key = [self groupingKeyForLine:line];

    NSMutableArray *group = [groupedLines objectForKey:key];
    if(group == nil)
    {
        group = [[NSMutableArray alloc] init];
        [groupedLines setObject:group forKey:key];
    }

    if(totalizeProducts) {
        int row = 0;
        for(OrderLine * groupLine in group)
        {
            if(groupLine.product.id == line.product.id)
            {
                groupLine.quantity += line.quantity;
                if (tableView != nil) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: row inSection: [self sectionForKey:key]];
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                }
                return;
            }
            row++;
        }
        line = [line copyWithZone:nil];
    }

    int row = [self insertionPointForLine:line inGroup:group];
    [group insertObject:line atIndex:row];
    
    if (tableView != nil) {
        int section = [self sectionForKey:key];
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow: row inSection: section];
        [tableView beginUpdates];
        if ([group count] == 1)
            [tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationTop];
        [tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
//        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (int) insertionPointForLine: (OrderLine *)lineToInsert inGroup: (NSMutableArray *)group {
    int i = 0;
    for(OrderLine *line in group) {
        switch(sortOrder) {
            case sortByOrder:
                if (line.sortOrder > lineToInsert.sortOrder)
                    return i;
                break;
            case sortByCreatedOn:
                if ([line.createdOn compare:lineToInsert.createdOn] == NSOrderedAscending)
                    return i;
                break;
            case sortByCategory:
                if (line.product.category.sortOrder > lineToInsert.product.category.sortOrder)
                    return i;
                break;
        }
        i++;
    }
    return i;
}
- (void) tableView:(UITableView *)tableView removeOrderLine:(OrderLine *)line {
    NSIndexPath *indexPath = [self indexPathForLine:line];
    if (indexPath == nil) return;
    NSMutableArray *group = [self groupForSection:indexPath.section];
    if (group == nil) return;
    [group removeObject:line];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSIndexPath *)indexPathForLine: (OrderLine *)line {
    if (line == nil) return nil;
    NSString *key = [self groupingKeyForLine:line];
    NSMutableArray *group = [groupedLines objectForKey:key];
    if (group == nil || key == nil)
        return nil;
    int section = [self sectionForKey:key];
    for(int row = 0; row < [group count]; row++) {
        if([group objectAtIndex:row] == line) {
            return [NSIndexPath indexPathForRow:row inSection:section];
        }        
    }
    return nil;
}

- (NSString *) groupingKeyForLine: (OrderLine *)line
{
    switch(grouping)
    {
        case noGrouping:
            return @"";
        case byCategory:
            return [NSString stringWithFormat:@"%d.%@", line.product.category.sortOrder, line.product.category.name];
        case bySeat:
            return [NSString stringWithFormat:@"Stoel %d", line.guest.seat + 1];
        case byCourse:
            return [NSString stringWithFormat:@"Gang %d", line.course.offset+ 1];
    }
    return @"";
}

- (NSString *) keyForSection:(int) section
{
    NSArray* sortedKeys = [[groupedLines allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

- (int) sectionForKey:(NSString *) key
{
    NSArray* sortedKeys = [[groupedLines allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys indexOfObject:key];
}

- (NSMutableArray *) groupForSection:(int) section
{
    NSString *key = [self keyForSection:section];
    return [groupedLines objectForKey:key];
}

- (OrderLine *) orderLineAtIndexPath: (NSIndexPath *)indexPath
{
    NSMutableArray *group = [self groupForSection: indexPath.section];
    if (group == nil) return nil;
    return [group objectAtIndex:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = [[groupedLines allKeys] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *group = [self groupForSection: section];
    if(group == nil)
        return 0;
    return [group count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(grouping == noGrouping) return nil;
    NSString *key = [self keyForSection:section];
    NSMutableArray *group = [groupedLines objectForKey:key];
    NSDecimalNumber *total = [NSDecimalNumber zero];
    for(OrderLine *line in group)
    {
        total = [total decimalNumberByAdding:[line.product.price decimalNumberByMultiplyingBy:[NSDecimalNumber numberWithInt: line.quantity]]];

    }
    return [NSString stringWithFormat:@"%@ (%@)", key, [Utils getAmountString: total withCurrency:YES]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    OrderLine *line = [self orderLineAtIndexPath:indexPath];

    OrderLineCell *cell = (OrderLineCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [OrderLineCell cellWithOrderLine:line isEditable: self.isEditable showPrice:showPrice showProperties: showProductProperties delegate: self.delegate rowHeight: rowHeight];
    }
//    cell.showProductProperties = self.showProductProperties;
//    cell.showPrice = self.showPrice;
//    cell.orderLine = line;

    cell.isInEditMode = cell.isSelected;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = rowHeight == 0 ? 44 : rowHeight;
    NSIndexPath *indexPathSelected = [tableView indexPathForSelectedRow];
    if (indexPathSelected != nil)
        if (indexPath.row == indexPathSelected.row && indexPath.section == indexPathSelected.section) {
            height += [OrderLineCell getExtraHeightForEditMode: [self orderLineAtIndexPath:indexPath] width:320];
        }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    [tableView endUpdates];
    OrderLineCell *cell = (OrderLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
        cell.isInEditMode = true;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    [tableView endUpdates];
    OrderLineCell *cell = (OrderLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
        cell.isInEditMode = false;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *group = [self groupForSection: indexPath.section];
    OrderLine *line = [group objectAtIndex:indexPath.row];
    if (cell != nil)
        [cell setBackgroundColor:line.product.category.color];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    
    NSMutableArray *group = [self groupForSection: indexPath.section];
    if(group == nil) return;
    OrderLine *line = [group objectAtIndex:indexPath.row];
    if(line == nil) return;
    
    ServiceResult *result = [[Service getInstance] deleteOrderLine: line.id];
    if(result == nil) return;
    
    if(result.isSuccess == false) {
        [ModalAlert inform:NSLocalizedString(result.error, nil)];
        return;
    }
    [group removeObject:line];
    // Delete the row from the data source
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [order removeOrderLine: line];
    if(self.invoicesViewController != nil)
        [invoicesViewController onUpdateOrder: self.order];
}

@end
