	//
//  InvoiceDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "InvoiceDataSource.h"
#import "Order.h"
#import "OrderLineCell.h"
#import "Service.h"
#import "ModalAlert.h"
#import "Utils.h"

@implementation InvoiceDataSource

@synthesize totalizeProducts, showFreeProducts, order, groupedLines, grouping, invoicesViewController, showProductProperties;

+ (InvoiceDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping totalizeProducts: (bool) totalize showFreeProducts: (bool)showFree showProductProperties: (bool)showProps
{
    InvoiceDataSource *source = [[InvoiceDataSource alloc] init];
    source.totalizeProducts = totalize;
    source.showFreeProducts = showFree;
    source.showProductProperties = showProps;
    source.order = order;
    source.grouping = grouping;
    return source;
}

- (void) setGrouping: (OrderGrouping) newGrouping
{
    grouping = 	newGrouping;
    self.groupedLines = [[NSMutableDictionary alloc] init];
    for(Course *course in order.courses)
    {
        for(OrderLine *line in course.lines)
        {
            if([line.product.price isEqualToNumber: [NSDecimalNumber zero]] == false || showFreeProducts) {
                NSString *key = [self groupingKeyForLine:line];
            
                NSMutableArray *group = [groupedLines objectForKey:key];
                if(group == nil)
                {
                    group = [[NSMutableArray alloc] init];
                    [groupedLines setObject:group forKey:key]; 
                }
                [self addLineToGroup: line group:group];        
            }
        }
    }
    return;    
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

- (void) addLineToGroup: (OrderLine *)line group: (NSMutableArray *) group
{
    if(totalizeProducts) {
        for(OrderLine * groupLine in group)
        {
            if(groupLine.product.id == line.product.id)
            {
                groupLine.quantity += line.quantity;
                return;
            }
        }
    }
    line.quantity = 1;
    [group addObject:line];
}

- (NSString *) keyForSection:(int) section
{
    NSArray* sortedKeys = [[groupedLines allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

- (NSMutableArray *) groupForSection:(int) section
{
    NSString *key = [self keyForSection:section];
    return [groupedLines objectForKey:key];
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
        total = [total decimalNumberByAdding:line.product.price];
    }
    return [NSString stringWithFormat:@"%@ (%@)", key, [Utils getAmountString: total withCurrency:YES]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    OrderLineCell *cell = (OrderLineCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderLineCell" owner:self options:nil] lastObject];
    }
    cell.showProductProperties = self.showProductProperties;
    NSMutableArray *group = [self groupForSection: indexPath.section];
    OrderLine *line = [group objectAtIndex:indexPath.row];
    cell.orderLine = line;
    
    return cell;
}	

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *group = [self groupForSection: indexPath.section];
    OrderLine *line = [group objectAtIndex:indexPath.row];
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
