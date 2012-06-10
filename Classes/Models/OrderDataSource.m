//
//  InvoiceDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OrderDataSource.h"
#import "Service.h"
#import "ModalAlert.h"
#import "Utils.h"
#import "NSDate-Utilities.h"
#import "SeatHeaderView.h"

@implementation OrderDataSource

@synthesize totalizeProducts, showFreeProducts, order, groupedLines, grouping, showProductProperties, showSeat, isEditable, delegate = _delegate, rowHeight, sortOrder, showPrice, fontSize, collapsableHeaders, showEmptySections, showStepper;

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
        switch(grouping) {
            case byCourse:
                group.title = NSLocalizedString(@"General", nil);
                for (Course *course in order.courses) {
                    group = [[OrderDataSourceSection alloc] init];
                    group.title = course.description;
                    group.isCollapsed = course.servedOn != nil;
                    if (course.servedOn != nil)
                        group.subTitle = [NSString stringWithFormat:NSLocalizedString(@"Served at %@", nil), [course.servedOn dateDiff]];
                    else
                    if (course.requestedOn != nil)
                        group.subTitle = [NSString stringWithFormat:NSLocalizedString(@"Requested at %@", nil), [course.requestedOn dateDiff]];
                    [groupedLines setObject:group forKey: [self keyForCourse: course]];
                }
                break;
            case bySeat:
                group.title = NSLocalizedString(@"Table", nil);
                [groupedLines setObject:group forKey: [self keyForGuest:nil]];
                for (Guest *guest in order.guests) {
                    group = [[OrderDataSourceSection alloc] init];
                    group.title = guest.description;
                    [groupedLines setObject:group forKey: [self keyForGuest: guest]];
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
    NSNumber *key = [self keyForOrderLine:line];

    bool isNewSection = NO;
    OrderDataSourceSection *group = [groupedLines objectForKey:key];
    if(group == nil)
    {
        group = [[OrderDataSourceSection alloc] init];
        group.title = [self stringForOrderLine:line];
        [groupedLines setObject:group forKey:key];
        isNewSection = YES;
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

    int row = [self insertionPointForLine:line inGroup:group];
    [group.lines insertObject:line atIndex:row];
    
    if (tableView != nil) {
        int section = [self sectionForKey:key];
        OrderDataSourceSection *group = [self groupForSection: section];
        if (group.isCollapsed == NO) {
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow: row inSection: section];
            [tableView beginUpdates];
            if (isNewSection)
                [tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [tableView endUpdates];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

-(void) logDataSource {
    for (int section = 0; section < [groupedLines count]; section++) {
        OrderDataSourceSection *group = [self groupForSection: section];
        NSLog(@"section %d", section);
        for (int row = 0; row < [group.lines count]; row++) {
            OrderLine *line1 = [group.lines objectAtIndex:row];
            NSLog(@"  row %d: %d x %@", row, line1.quantity, line1.product.name);
        }
    }
}

- (void) tableView:(UITableView *)tableView addSection: (int) section {
    switch(grouping) {
        case bySeat:
            {
            Guest *guest = [order.guests objectAtIndex:section-1];
            OrderDataSourceSection * group = [[OrderDataSourceSection alloc] init];
            group.title = guest.description;
            [groupedLines setObject:group forKey: [self keyForGuest: guest]];
            break;
            }
        case byCourse:
            {
            Course *course = [order.courses objectAtIndex:section-1];
            OrderDataSourceSection * group = [[OrderDataSourceSection alloc] init];
            group.title = course.description;
            [groupedLines setObject:group forKey: [self keyForCourse: course]];
            break;
            }
        case byCategory:
            {
            break;
            }
        case noGrouping:
            break;
    }

    if (tableView != nil) {
        [tableView beginUpdates];
        [tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }
}


- (NSMutableArray *)getGuestsForProduct: (Product *)product andKey: (NSNumber *)aKey {
    NSMutableArray *guests = [[NSMutableArray alloc] init];
    if (product != nil) {
        for (OrderLine *line in order.lines) {
            if (line.guest != nil && line.product.id == product.id) {
                NSNumber *key = [self keyForOrderLine:line];
                if ([aKey isEqualToNumber:key])
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
//    if ([group.lines count] == 0) {
//        NSNumber *key = [self keyForOrderLine:line];
//        [groupedLines removeObjectForKey: key];
//    }

    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
    if (totalizeProducts) {
        NSNumber *groupKey = [self keyForOrderLine:line];
        for(OrderLine *l in order.lines) {
            if ([[self keyForOrderLine:l] isEqualToNumber:groupKey] && l.product.id == line.product.id)
                [itemsToDelete addObject:l];
        }
    }
    else {
        [itemsToDelete addObject:line];
    }

    for(OrderLine *l in itemsToDelete) {
        if (l.id != -1) {
            ServiceResult *result = [[Service getInstance] deleteOrderLine: l.id];
            if(result == nil) return;

            if(result.isSuccess == false) {
                [ModalAlert inform:NSLocalizedString(result.error, nil)];
                return;
            }
        }
    }
    for (OrderLine *line in itemsToDelete) {
        [order removeOrderLine:line];
    }
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    if ([_delegate respondsToSelector:@selector(didUpdateOrder:)])
        return [_delegate didUpdateOrder: self.order];

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
    NSNumber *key = [self keyForOrderLine:line];
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

- (NSNumber *) keyForOrderLine: (OrderLine *)line
{
    switch(grouping)
    {
        case noGrouping:
            return [NSNumber numberWithInt:1];
        case byCategory:
            return [NSNumber numberWithInt: (line.product.category.sortOrder << 16) + line.product.category.id];
        case bySeat:
            return [self keyForGuest: line.guest];
        case byCourse:
            return [self keyForCourse: line.course];
    }
    return [NSNumber numberWithInt:1];
}

- (NSString *) stringForOrderLine: (OrderLine *)line
{
    switch(grouping)
    {
        case noGrouping:
            return @"";
        case byCategory:
            return line.product.category.name;
        case bySeat:
            return line.guest.description;
        case byCourse:
            return line.course.description;
    }
    return @"";
}

- (NSNumber *) keyForCourse: (Course *)course {
    if (course == nil)
        return [NSNumber numberWithInt:-1];
    return [NSNumber numberWithInt:course.offset];
}

- (NSNumber *) keyForGuest: (Guest *)guest {
    if (guest == nil)
        return [NSNumber numberWithInt:-1];
    return [NSNumber numberWithInt: guest.seat];
}

- (Guest *) guestForKey:(NSNumber *)key {
    int seat = [key intValue];
    if (seat == -1)
        return nil;
    return [order getGuestBySeat:seat];
}

- (Course *) courseForKey:(NSNumber *)key {
    int offset = [key intValue];
    if (offset == -1)
        return nil;
    return [order getCourseByOffset:offset];
}

- (NSNumber *) keyForSection:(int) section
{
    NSArray* sortedKeys = [[groupedLines allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if (section >= [sortedKeys count])
        return nil;
    return [sortedKeys objectAtIndex:section];
}

- (int) sectionForKey:(NSNumber *) key
{
    NSArray* sortedKeys = [[groupedLines allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys indexOfObject:key];
}

- (OrderDataSourceSection *) groupForSection:(int) section
{
    NSNumber *key = [self keyForSection:section];
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
        NSLog(@"No orderline at indexpath %d %d", indexPath.section, indexPath.row);
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
    return numberOfLines;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(grouping == noGrouping) return nil;
    NSNumber *key = [self keyForSection:section];
    OrderDataSourceSection *group = [groupedLines objectForKey:key];
    NSString *title = group.title;
    if (showPrice) {
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


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return -10;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(grouping == noGrouping) return nil;
    OrderDataSourceSection *sectionInfo = [self groupForSection:section];
    CGFloat height = [self tableView: tableView heightForHeaderInSection: section];
    if (grouping == bySeat) {
        Guest *guest = [self guestForKey:[self keyForSection: section]];
        return [SeatHeaderView viewWithFrame: CGRectMake(0,0,tableView.bounds.size.width,height) forGuest: guest table: order.table showAmount:showPrice];
    }
    if (collapsableHeaders == false)
        return nil;
    NSNumber *headerKey = [self keyForSection:section];
    NSMutableArray *guestsWithFood = [[NSMutableArray alloc] init];
    for (OrderLine *line in self.order.lines) {
        if (YES) {
            if (line.guest != nil) {
                NSNumber *key = [self keyForOrderLine:line];
                if ([headerKey isEqualToNumber:key]) {
                    [guestsWithFood addObject:line.guest];
                }
            }
        }
    }
    CollapseTableViewHeader *viewHeader = [[CollapseTableViewHeader alloc] initWithFrame:CGRectMake(0,0,tableView.bounds.size.width,height) section:section delegate: _delegate  tableView: tableView guests: guestsWithFood isExpanded: (BOOL)sectionInfo.isCollapsed == false isSelected: sectionInfo.isSelected];
    viewHeader.backgroundColor = tableView.backgroundColor;
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
        BOOL canEdit = YES;
        OrderLine *orderLine = [self orderLineAtIndexPath:indexPath];
        if ([_delegate respondsToSelector:@selector(canEditOrderLine:)])
            if ([_delegate canEditOrderLine:orderLine] == NO)
                canEdit = NO;
        if (canEdit) {
            NSIndexPath *indexPathSelected = [tableView indexPathForSelectedRow];
            if (indexPathSelected != nil)
                if (indexPath.row == indexPathSelected.row && indexPath.section == indexPathSelected.section) {
                    height += [OrderLineCell getExtraHeightForEditMode: orderLine width:320];
                }
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

- (CollapseTableViewHeader *) tableView: (UITableView *)tableView headerViewForSection:(NSInteger)section {
    for(UIView *view in tableView.subviews) {
        if ([view isKindOfClass:[CollapseTableViewHeader class]]) {
            CollapseTableViewHeader *viewHeader = (CollapseTableViewHeader *) view;
            if (viewHeader.section == section)
                return viewHeader;
        }
    }
    return nil;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderLine *line = [self orderLineAtIndexPath:indexPath];
    if (line == nil)
        return NO;
    if ([_delegate respondsToSelector:@selector(canEditOrderLine:)])
        return [_delegate canEditOrderLine: line];
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView totalizeProducts:(BOOL)totalize {
    [self logDataSource];

    totalizeProducts = !totalizeProducts;

    if (totalizeProducts == false)
        [self regroupOnTotalize];

    NSMutableArray *indexPathsInsert = [[NSMutableArray alloc] init];
    NSMutableArray *indexPathsDelete = [[NSMutableArray alloc] init];
    NSMutableArray *indexPathsReload = [[NSMutableArray alloc] init];
    for (int section = 0; section < [tableView numberOfSections]; section++) {
        OrderDataSourceSection *group = [self groupForSection: section];
        if (group.isCollapsed == NO) {
            for (int row = 0; row < [group.lines count]; row++) {
                OrderLine *line1 = [group.lines objectAtIndex:row];
                for (int j = 0; j < row; j++) {
                    OrderLine *line2 = [group.lines objectAtIndex:j];
                    if (line1.product.id == line2.product.id) {
                        if (totalizeProducts) {
                            [indexPathsDelete addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                            NSLog(@"delete s:%d r:%d", section, row);
                        }
                       else {
                            [indexPathsInsert addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                            NSLog(@"insert s:%d r:%d", section, row);
                        }
                        NSIndexPath *reload = [NSIndexPath indexPathForRow:j inSection:section];
                        if ([indexPathsReload containsObject:reload] == false)
                            [indexPathsReload addObject: reload];
                        break;
                    }
                }
            }
        }
    }
    if (totalizeProducts)
        [self regroupOnTotalize];

    [self logDataSource];

    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths: indexPathsReload withRowAnimation:UITableViewRowAnimationFade];
    [tableView deleteRowsAtIndexPaths: indexPathsDelete withRowAnimation:UITableViewRowAnimationTop];
    [tableView insertRowsAtIndexPaths: indexPathsInsert withRowAnimation:UITableViewRowAnimationTop];
    [tableView endUpdates];

//    for (int section = 0; section < [tableView numberOfSections]; section++) {
//        for (int row = 0; row < [tableView numberOfRowsInSection:section]; row++) {
//            [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationMiddle];
//        }
//    }
}

- (void) regroupOnTotalize {
    for (int section = 0; section < [[groupedLines allKeys] count]; section++) {
        OrderDataSourceSection *group = [self groupForSection: section];
        [group.lines removeAllObjects];
    }
    for(OrderLine *line in order.lines)
    {
        [self tableView:nil addLine:line];
    }
}

- (void) highlightRowsInTableView:(UITableView *)tableView forSeat:(int)seat {
    for (int section = 0; section < [tableView numberOfSections]; section++) {
        for (int row = 0; row < [tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            OrderLine *line = [self orderLineAtIndexPath:indexPath];
            OrderLineCell *cell = (OrderLineCell *) [tableView cellForRowAtIndexPath:indexPath];
            if (line.guest != nil && line.guest.seat == seat) {
                cell.isBlinking = YES;
            }
            else {
                cell.isBlinking = NO;
            }
        }
    }
}


@end
