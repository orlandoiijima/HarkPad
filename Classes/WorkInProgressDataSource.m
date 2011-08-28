//
//  WorkInProgressDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "WorkInProgressDataSource.h"


@implementation WorkInProgressDataSource

@synthesize workInProgress;

//+ (WorkInProgressDataSource *) dataSource
//{
//    WorkInProgressDataSource *source = [[WorkInProgressDataSource alloc] init];
//    source.workInProgress = [[Service getInstance] getWorkInProgress];
//    return source;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [workInProgress count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"Tap om gang te serveren";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    WorkInProgressTableCell *cell = (WorkInProgressTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WorkInProgressTableCell" owner:self options:nil] lastObject];
    }

    WorkInProgress *work = [workInProgress objectAtIndex:indexPath.row];
    
    cell.labelTable.text = work.table.name;
    int interval = (int)[[NSDate date] timeIntervalSinceDate: work.course.requestedOn];
    cell.labelTimer.text = [NSString stringWithFormat:@"%d\"", interval / 60];
    cell.labelCourse.text = @"";
    for(ProductCount *p in work.productCount)
    {
        if([cell.labelCourse.text length] > 0)
            cell.labelCourse.text = [NSString stringWithFormat:@"%@%@", cell.labelCourse.text, @", "];   
        NSString *product = p.product.key		;
        if(p.count > 1)
            product = [NSString stringWithFormat:@"%dx %@", p.count, product];
        cell.labelCourse.text = [NSString stringWithFormat:@"%@%@", cell.labelCourse.text, product];   
    }
    return cell;
}	

- (void) deleteLine: (WorkInProgress*) itemToDelete fromTableView: (UITableView *)tableView 
{
    int row = 0;
    for (WorkInProgress *item in workInProgress) {
        if(item.course.id == itemToDelete.course.id)
            break;
        row++;
    }
    if(row >= [workInProgress count]) return;
    
    [tableView beginUpdates];
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    [deleteIndexPaths addObject: [NSIndexPath indexPathForRow:(NSUInteger) row inSection:(NSUInteger) 0]];
    [tableView deleteRowsAtIndexPaths: deleteIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [workInProgress removeObject: itemToDelete];
    [tableView endUpdates];	
}


@end
