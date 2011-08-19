//
//  KitchenStatisticsDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 10-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "KitchenStatisticsDataSource.h"
#import "Service.h"

@implementation KitchenStatisticsDataSource

@synthesize groupedTotals;

#pragma mark - Table view data source

+ (KitchenStatisticsDataSource *) dataSource
{
    KitchenStatisticsDataSource *source = [[KitchenStatisticsDataSource alloc] init];
    NSMutableArray *backlog = [[Service getInstance] getBacklogStatistics];
    source.groupedTotals = [[NSMutableDictionary alloc] init];
    for(Backlog *total in backlog) {
        NSString *key = [NSString stringWithFormat:@"%d %@", total.product.category.sortOrder, total.product.category.name];
        NSMutableArray *totals = [source.groupedTotals objectForKey:key];
        if(totals == nil)
        {
            totals = [[NSMutableArray alloc] init];
            [source.groupedTotals setObject: totals forKey:key];
        }
        [totals addObject:total];
    }
    return source;
}

- (NSString *) keyForSection: (int) section
{
    if(section > [groupedTotals count])
        return @"";
    NSArray* sortedKeys = [[groupedTotals allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [groupedTotals count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [self keyForSection:section];
    return [[groupedTotals objectForKey:key] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self keyForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    NSString *key = [self keyForSection: indexPath.section];
    Backlog *backlog = [[groupedTotals objectForKey:key] objectAtIndex: indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];

        float width = 50;
        float x = tableView.bounds.size.width - 8*width - width - 100;
        float y = 5;
        float height = cell.contentView.bounds.size.height - 10;
        for(int i=0; i < 8; i++) {
            UILabel *label = [self addCountLabelWithFrame:CGRectMake(x, y, width, height) backgroundColor: backlog.product.category.color cell:cell];
            label.tag = 100+i;
            x += width;
        }
        UILabel *label = [self addCountLabelWithFrame:CGRectMake(x, y, width, height) backgroundColor: backlog.product.category.color cell:cell];
        label.tag = 200;
    }

    int total = 0;
    for(int i=0; i < 8; i++) {
        NSNumber *count = [backlog.totals objectForKey:[NSString stringWithFormat:@"%d", i]];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100+i];
        label.text = count == nil ? @"-" : [NSString stringWithFormat:@"%@", count];
        label.highlightedTextColor = [UIColor whiteColor];
        total += [count intValue];
    }

    UILabel *label = (UILabel *)[cell.contentView viewWithTag:200];
    label.highlightedTextColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%d", total];
    
    cell.textLabel.backgroundColor = backlog.product.category.color;
    cell.textLabel.shadowColor = [UIColor lightGrayColor];
    cell.textLabel.text = backlog.product.key;
    
    return cell;
}	

- (UILabel *) addCountLabelWithFrame: (CGRect) frame backgroundColor: (UIColor *) color cell: (UITableViewCell *)cell
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = color;
    label.shadowColor = [UIColor lightGrayColor];
    label.textAlignment = UITextAlignmentRight;
    [cell.contentView addSubview:label];
    return label;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *key = [self keyForSection: indexPath.section];
    Backlog *backlog = [[groupedTotals objectForKey:key] objectAtIndex: indexPath.row];
    cell.backgroundColor = backlog.product.category.color;
}


@end
