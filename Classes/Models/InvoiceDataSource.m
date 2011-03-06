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

@implementation InvoiceDataSource

@synthesize order, groupedLines, grouping;

+ (InvoiceDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping
{
    InvoiceDataSource *source = [[InvoiceDataSource alloc] init];
    source.order = order;
    source.grouping = grouping;
    return source;
}

- (void) setGrouping: (OrderGrouping) newGrouping
{
    grouping = newGrouping;
    groupedLines = [[NSMutableDictionary alloc] init];
    for(Course *course in order.courses)
    {
        for(OrderLine *line in course.lines)
        {
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
    return;    
}

- (NSString *) groupingKeyForLine: (OrderLine *)line
{
    switch(grouping)
    {
        case byCategory:
            return line.product.category.name;
        case bySeat:
            return [NSString stringWithFormat:@"Stoel %d", line.guest.seat + 1];
        case byCourse:
            return [NSString stringWithFormat:@"Gang %d", line.course.offset+ 1];
    }
    return @"";
}

- (void) addLineToGroup: (OrderLine *)line group: (NSMutableArray *) group
{
    for(OrderLine * groupLine in group)
    {
        if(groupLine.product.id == line.product.id)
        {
            groupLine.quantity += line.quantity;
            return;
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
    return [[groupedLines allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *group = [self groupForSection: section];
    if(group == nil)
        return 0;
    return [group count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [self keyForSection:section];
    NSMutableArray *group = [groupedLines objectForKey:key];
    NSDecimalNumber *total = [NSDecimalNumber zero];
    for(OrderLine *line in group)
    {
        total = [total decimalNumberByAdding:[line getAmount]];
    }
    return [NSString stringWithFormat:@"%@ (€ %.02f)", key, [total doubleValue]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    OrderLineCell *cell = (OrderLineCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderLineCell" owner:self options:nil] lastObject];
    }
    
    NSMutableArray *group = [self groupForSection: indexPath.section];
    OrderLine *line = [group objectAtIndex:indexPath.row];
    cell.orderLine = line;
    
    return cell;
}	


@end
