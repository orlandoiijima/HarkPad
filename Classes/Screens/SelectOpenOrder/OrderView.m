//
//  OrderView.m
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OrderView.h"
#import "Utils.h"
#import "SelectOpenOrder.h"

@implementation OrderView

@synthesize order = _order, dataSource, tableView, label, isSelected = _isSelected;

- (id)initWithFrame:(CGRect)frame order: (Order *)anOrder delegate: (id<OrderViewDelegate>) delegate
{
    self = [super initWithFrame:frame];
    if (self) {

        if ([anOrder.lines count] > 0) {
            self.label = [OrderTag tagWithFrame:CGRectMake(0, 2, frame.size.width, 34) andOrder: anOrder delegate: delegate];
            [self addSubview:self.label];
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.label.frame.size.height + 2, frame.size.width, frame.size.height - self.label.frame.size.height - 10) style:UITableViewStyleGrouped];
            self.tableView.backgroundColor = [UIColor clearColor];
            self.tableView.backgroundView = nil;
            self.tableView.sectionHeaderHeight = 1;
            [self addSubview:self.tableView];
            self.tableView.delegate = self;
        }
        else {
            UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 20, 10)];
            infoLabel.backgroundColor = [UIColor clearColor];
            infoLabel.textColor = [UIColor grayColor];
            infoLabel.numberOfLines = 0;
            infoLabel.lineBreakMode = UILineBreakModeWordWrap;
            [self addSubview:infoLabel];
            if (anOrder.id == byNothing) {
                infoLabel.text = NSLocalizedString(@"Nieuwe rekening", nil);
            }
            else
            if (anOrder.id == byReservation)
                infoLabel.text = NSLocalizedString(@"Klik om reservering te kiezen", nil);
            else
                infoLabel.text = NSLocalizedString(@"Klik om personeelslid te kiezen", nil);
            infoLabel.textAlignment = UITextAlignmentCenter;
        }
        self.order = anOrder;
    }
    return self;
}

- (void)setOrder: (Order *)newOrder {
    _order = newOrder;
    dataSource = [OrderDataSource dataSourceForOrder:newOrder grouping:None totalizeProducts:YES showFreeProducts:NO showProductProperties:NO isEditable:NO];
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
