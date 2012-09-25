//
//  SelectReservationView.m
//  HarkPad
//
//  Created by Willem Bison on 02/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "SelectReservationView.h"
#import "ReservationDataSource.h"
#import "NSDate-Utilities.h"
#import "SelectItemDelegate.h"

@implementation SelectReservationView

@synthesize dataSource = _dataSource, label, tableView, emptyLabel, delegate;
@dynamic selectedReservation;

- (id)initWithFrame:(CGRect)frame delegate: (id<SelectItemDelegate>) aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {

        self.delegate = aDelegate;

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 20)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.label.text = NSLocalizedString(@"Select reservation or 'walk-in':", nil);
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.shadowColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];

        self.tableView = [[UITableView alloc]
                initWithFrame:CGRectMake(0, self.label.frame.origin.y + self.label.frame.size.height, frame.size.width, frame.size.height - (self.label.frame.origin.y + self.label.frame.size.height))
                        style:UITableViewStyleGrouped];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        [self addSubview:self.tableView];

        self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.emptyLabel.autoresizingMask = (UIViewAutoresizing) -1;
        self.emptyLabel.text = NSLocalizedString(@"No reservations", nil);
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.shadowColor = [UIColor whiteColor];
        self.emptyLabel.backgroundColor = [UIColor clearColor];
        self.emptyLabel.hidden = YES;
        [self addSubview:self.emptyLabel];

    }
    return self;
}

- (void)setDataSource:(ReservationDataSource *)aDataSource {
    _dataSource = aDataSource;
    self.tableView.dataSource = _dataSource;
    [self.tableView reloadData];
    if ([[_dataSource reservations] count] == 0) {
        self.emptyLabel.hidden = NO;
        self.tableView.hidden = YES;
    }
    else {
        self.emptyLabel.hidden = YES;
        self.tableView.hidden = NO;

        NSDate *showFrom = [[NSDate date] dateByAddingTimeInterval: -60 * 30];
        for (int section = 0; section < [self.tableView numberOfSections]; section++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
            Reservation *reservation = [_dataSource getReservation: indexPath];
            if (reservation != nil)
                if ([reservation.startsOn isLaterThanDate:showFrom]) {
                    [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    break;
                }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reservation *reservation = [_dataSource getReservation:indexPath];
    if ([delegate respondsToSelector:@selector(didSelectItem:)])
        [delegate didSelectItem:reservation];
}

- (void) setSelectedReservation: (Reservation *)reservationToSelect {
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            Reservation *reservation = [_dataSource getReservation: indexPath];
            if (reservation != nil && reservationToSelect.id == reservation.id) {
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
    }
}

- (Reservation *) selectedReservation {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath == nil) return nil;
    return [_dataSource getReservation:indexPath];
}

@end
