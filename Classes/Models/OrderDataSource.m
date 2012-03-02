//
//  InvoiceDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "OrderDataSource.h"
#import "Order.h"
#import "OrderLineCell.h"
#import "Service.h"
#import "ModalAlert.h"
#import "Utils.h"
#import "NSDate-Utilities.h"

@implementation OrderDataSource

@synthesize totalizeProducts, showFreeProducts, order, groupedLines, grouping, hostController, showProductProperties, showSeat, isEditable, delegate = _delegate, rowHeight, sortOrder, showPrice, fontSize, collapsableHeaders, showEmptySections, showStepper;

+ (OrderDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping totalizeProducts: (bool) totalize showFreeProducts: (bool)showFree showProductProperties: (bool)showProps isEditable: (bool) isEditable showPrice: (bool)showPrice showEmptySections: (BOOL) showEmptySections fontSize: (float)fontSize
{
    OrderDataSource *source = [[OrderDataSource alloc] init];
    source.totalizeProducts = totalize;
    source.showFreeProducts = showFree;
    source.showProductProperties = showProps;
    source.showPrice = showPrice;
    source.showEmptySections = showEmptySections;
    source.fontSize = fontSize;
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

    if (showEmptySections) {
        OrderDataSourceSection *group = [[OrderDataSourceSection alloc] init];
        [groupedLines setObject:group forKey: [self keyForCourse:nil]];
        OrderLine *line = [[OrderLine alloc] init];
        [group.lines addObject: line];
        switch(grouping) {
            case byCourse:
                for (Course *course in order.courses) {
                    OrderDataSourceSection *group = [[OrderDataSourceSection alloc] init];
                    group.isCollapsed = course.servedOn != nil;
                    if (course.servedOn != nil)
                        group.subTitle = [NSString stringWithFormat:NSLocalizedString(@"Served at %@", nil), [course.servedOn dateDiff]];
                    else
                    if (course.requestedOn != nil)
                        group.subTitle = [NSString stringWithFormat:NSLocalizedString(@"Requested at %@", nil), [course.requestedOn dateDiff]];
                    [groupedLines setObject:group forKey: [self keyForCourse: course]];
                    OrderLine *line = [[OrderLine alloc] init];
                    line.course = course;
                    [group.lines addObject: line];
                }
                break;
            case bySeat:
                [groupedLines setObject:group forKey: [self keyForGuest:nil]];
                for (Guest *guest in order.guests) {
                    OrderDataSourceSection *group = [[OrderDataSourceSection alloc] init];
                    [groupedLines setObject:group forKey: [self keyForGuest: guest]];
                    OrderLine *line = [[OrderLine alloc] init];
                    line.guest = guest;
                    [group.lines addObject: line];
                }
                break;
            case noGrouping:
            case byCategory:
                NSLog(@"");
                break;
        }
    }

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

    OrderDataSourceSection *group = [groupedLines objectForKey:key];
    if(group == nil)
    {
        group = [[OrderDataSourceSection alloc] init];
        [groupedLines setObject:group forKey:key];
    }

    if(totalizeProducts) {
        int row = 0;
        for(OrderLine * groupLine in group.lines)
        {
            if(groupLine.product.id == line.product.id)
            {
                groupLine.quantity += line.quantity;
                if (tableView != nil) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: row inSection: [self sectionForKey:key]];
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                }
                return;
            }
            row++;
        }
        line = [line copyWithZone:nil];
    }

    BOOL isDummyReplacement = NO;
    if (showEmptySections) {
        if ([group.lines count] == 1) {
            OrderLine *singleLine = [group.lines objectAtIndex:0];
            if (singleLine.product == nil) {
                [group.lines removeObjectAtIndex:0];
                isDummyReplacement = YES;
            }
        }
    }

    int row = [self insertionPointForLine:line inGroup:group];
    [group.lines insertObject:line atIndex:row];
    
    if (tableView != nil) {
        int section = [self sectionForKey:key];
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow: row inSection: section];
        [tableView beginUpdates];
        if (isDummyReplacement) {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            if ([group.lines count] == 1) {
                [tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationTop];
            }
            [tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        [tableView endUpdates];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSMutableArray *)getGuestsForProduct: (Product *)product andKey: (NSString *)aKey {
    NSMutableArray *guests = [[NSMutableArray alloc] init];
    if (product != nil) {
        for (OrderLine *line in order.lines) {
            if (line.guest != nil && line.product.id == product.id) {
                NSString *key = [self groupingKeyForLine:line];
                if ([aKey isEqualToString:key])
                    [guests addObject:line.guest];
            }
        }
    }
    return guests;
}

- (int) insertionPointForLine: (OrderLine *)lineToInsert inGroup: (OrderDataSourceSection *)group {
    int i = 0;
    for(OrderLine *line in group.lines) {
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
    OrderDataSourceSection *group = [self groupForSection:indexPath.section];
    if (group == nil) return;
    [group.lines removeObject:line];
    if ([group.lines count] == 0) {
        NSString *key = [self groupingKeyForLine:line];
        [groupedLines removeObjectForKey: key];
    }

    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
    if (totalizeProducts) {
        NSString *groupKey = [self groupingKeyForLine:line];
        for(OrderLine *l in order.lines) {
            if ([[self groupingKeyForLine:l] isEqualToString:groupKey] && l.product.id == line.product.id)
                [itemsToDelete addObject:l];
        }
    }
    else {
        [itemsToDelete addObject:line];
    }

    for(OrderLine *l in itemsToDelete) {
        if (l.id != 0) {
            ServiceResult *result = [[Service getInstance] deleteOrderLine: l.id];
            if(result == nil) return;

            if(result.isSuccess == false) {
                [ModalAlert inform:NSLocalizedString(result.error, nil)];
                return;
            }
        }
    }
    [order.lines removeObjectsInArray:itemsToDelete];
    
    if ([group.lines count] == 0)
        [tableView deleteSections:[NSIndexSet indexSetWithIndex: indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
    else
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    
    if(self.hostController != nil) {
        if([self.hostController respondsToSelector:@selector(onUpdateOrder:)]) {
            [hostController onUpdateOrder: self.order];
        }
    }
}

- (void) tableView:(UITableView *)tableView collapseSection: (NSUInteger)section
{
    OrderDataSourceSection *group = [self groupForSection:section];
    if (group == nil) return;
    if (group.isCollapsed) return;
    group.isCollapsed = YES;
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
    for(NSUInteger row = 0; row < [group.lines count]; row++) {
        [itemsToDelete addObject: [NSIndexPath indexPathForRow: row inSection: section]];
    }
    [tableView deleteRowsAtIndexPaths:itemsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) tableView:(UITableView *)tableView expandSection: (NSUInteger)sectionToExpand collapseAllOthers:(BOOL)collapseOthers
{
    OrderDataSourceSection *group = [self groupForSection:sectionToExpand];
    if (group == nil) return;
    if (group.isCollapsed == NO) return;
    group.isCollapsed = NO;
    NSMutableArray *itemsToInsert = [[NSMutableArray alloc] init];
    for(NSUInteger row = 0; row < [group.lines count]; row++) {
        [itemsToInsert addObject: [NSIndexPath indexPathForRow: row inSection: sectionToExpand]];
    }
    [tableView insertRowsAtIndexPaths:itemsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];

    if (collapseOthers) {
        for (int section = 0; section < [tableView numberOfSections]; section++) {
            if (section != sectionToExpand)
                [self tableView:tableView collapseSection:section];
        }
    }
}

- (NSIndexPath *)indexPathForLine: (OrderLine *)line {
    if (line == nil) return nil;
    NSString *key = [self groupingKeyForLine:line];
    OrderDataSourceSection *group = [groupedLines objectForKey:key];
    if (group == nil || key == nil)
        return nil;
    int section = [self sectionForKey:key];
    for(int row = 0; row < [group.lines count]; row++) {
        if([group.lines objectAtIndex:row] == line) {
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
            return [self keyForGuest: line.guest];
        case byCourse:
            return [self keyForCourse: line.course];
    }
    return @"";
}

- (NSString *) keyForCourse: (Course *)course {
    if (course == nil)
        return NSLocalizedString(@"General", nil);
    return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Course", nil), [Utils getCourseChar: course.offset]];
}

- (NSString *) keyForGuest: (Guest *)guest {
    if (guest == nil)
        return NSLocalizedString(@"Table", nil);
    return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Seat", nil), [Utils getSeatChar: guest.seat]];
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

- (OrderDataSourceSection *) groupForSection:(int) section
{
    NSString *key = [self keyForSection:section];
    return [groupedLines objectForKey:key];
}

- (OrderLine *) orderLineAtIndexPath: (NSIndexPath *)indexPath
{
    OrderDataSourceSection *group = [self groupForSection: indexPath.section];
    if (group == nil) return nil;
    if (indexPath.row >= [group.lines count]) {
        if (indexPath.row == 0 && showEmptySections) {
            return nil;
        }
        NSLog(@"Error");
        return nil;
    }
    return [group.lines objectAtIndex:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = [[groupedLines allKeys] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    OrderDataSourceSection *group = [self groupForSection: section];
    if(group == nil)
        return 0;
    if (group.isCollapsed)
        return 0;
    int numberOfLines = [group.lines count];
    if (numberOfLines == 0 && showEmptySections)
        return 1;
    return numberOfLines;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(grouping == noGrouping) return nil;
    NSString *key = [self keyForSection:section];
    NSString *title = [NSString stringWithString:key];
    if (showPrice) {
        OrderDataSourceSection *group = [groupedLines objectForKey:key];
        NSDecimalNumber *total = [NSDecimalNumber zero];
        for(OrderLine *line in group.lines)
        {
            if (line.product != nil)
                total = [total decimalNumberByAdding:[line.product.price decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt: line.quantity]]];
        }
        title = [title stringByAppendingFormat:@" (%@)", [Utils getAmountString: total withCurrency:YES]];
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return -10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(grouping == noGrouping) return nil;
    if (collapsableHeaders == false)
        return nil;
    CGFloat height = [self tableView: tableView heightForHeaderInSection: section];
    NSString *headerKey = [self keyForSection:section];
    NSMutableArray *guestsWithFood = [[NSMutableArray alloc] init];
    for (OrderLine *line in self.order.lines) {
        if (YES) {
            if (line.guest != nil) {
                NSString *key = [self groupingKeyForLine:line];
                if ([headerKey isEqualToString:key]) {
                    [guestsWithFood addObject:line.guest];
                }
            }
        }
    }

    CollapseTableViewHeader *viewHeader = [[CollapseTableViewHeader alloc] initWithFrame:CGRectMake(0,0,tableView.bounds.size.width,height) section:section delegate: self  tableView: tableView guests: guestsWithFood];
    return viewHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    OrderLine *line = [self orderLineAtIndexPath:indexPath];

    OrderLineCell *cell = (OrderLineCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSMutableArray *guests;
        if (totalizeProducts)
            guests = [self getGuestsForProduct: line.product andKey: [self keyForSection:indexPath.section]];
        else
            guests = line.guest == nil ? nil : [NSMutableArray arrayWithObject:line.guest];
        cell = [OrderLineCell cellWithOrderLine:line isEditable: self.isEditable showPrice:showPrice showProperties: showProductProperties showSeat:showSeat showStepper: showStepper guests: guests delegate: self.delegate rowHeight: rowHeight fontSize: fontSize];
    }

    cell.isInEditMode = cell.isSelected;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = rowHeight == 0 ? 44 : rowHeight;
    if (isEditable) {
        NSIndexPath *indexPathSelected = [tableView indexPathForSelectedRow];
        if (indexPathSelected != nil)
            if (indexPath.row == indexPathSelected.row && indexPath.section == indexPathSelected.section) {
                height += [OrderLineCell getExtraHeightForEditMode: [self orderLineAtIndexPath:indexPath] width:320];
            }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    [tableView endUpdates];
    OrderLineCell *cell = (OrderLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
        cell.isInEditMode = true;

    if ([_delegate respondsToSelector:@selector(didSelectOrderLine:)])
        [_delegate didSelectOrderLine:cell.orderLine];
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
    if (cell == nil) return;

    OrderLine *line = [self orderLineAtIndexPath:indexPath];
    if (line == nil) return;

    if (line.product != nil)
        [cell setBackgroundColor:line.product.category.color];
    else
        [cell setBackgroundColor: [UIColor whiteColor]];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) return;

    OrderLine *line = [self orderLineAtIndexPath:indexPath];
    if(line == nil) return;
    [self tableView:tableView removeOrderLine:line];
}

@end
