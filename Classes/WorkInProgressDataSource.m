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

+ (WorkInProgressDataSource *) dataSource
{
    WorkInProgressDataSource *source = [[WorkInProgressDataSource alloc] init];
    source.workInProgress = [[Service getInstance] getWorkInProgress];
    return source;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [workInProgress count];
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


@end
