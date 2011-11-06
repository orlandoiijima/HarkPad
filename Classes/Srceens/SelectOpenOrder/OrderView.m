//
//  OrderView.m
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderView.h"
#import "Utils.h"

@implementation OrderView

@synthesize order = _order, dataSource, tableView, label, isSelected = _isSelected;

- (id)initWithFrame:(CGRect)frame order: (Order *)anOrder
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [OrderTag tagWithFrame:CGRectMake(0, 2, frame.size.width, 25) andOrder: anOrder];
        [self addSubview:self.label];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.label.frame.size.height + 2, frame.size.width, frame.size.height - self.label.frame.size.height - 6) style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = nil;
        [self addSubview:self.tableView];
        self.order = anOrder;

        self.tableView.delegate = self;
    }
    return self;
}

- (void)setOrder: (Order *)newOrder {
    _order = newOrder;
    dataSource = [InvoiceDataSource dataSourceForOrder:newOrder grouping:None totalizeProducts:YES showFreeProducts:NO showProductProperties:NO];
    self.tableView.dataSource = dataSource;
}

- (void)setIsSelected: (bool)selected {
    self.backgroundColor = selected ? [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] : [UIColor clearColor];
    self.label.backgroundColor = self.backgroundColor;
    _isSelected = selected;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 26;
}

@end
