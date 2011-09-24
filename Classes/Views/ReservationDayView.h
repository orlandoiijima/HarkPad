//
//  ReservationDayView.h
//  HarkPad
//
//  Created by Willem Bison on 06-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReservationDataSource.h"

@interface ReservationDayView : UIView {
    UILabel *dateLabel;
    UILabel *dayLabel;
    ReservationDataSource *dataSource;
    UITableView *table;
    NSMutableDictionary *countLabels;
    NSDate *date;
}

@property (retain) NSMutableDictionary *countLabels;
@property (retain) UITableView *table;
@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) IBOutlet UILabel *dayLabel;
@property (retain, nonatomic) ReservationDataSource *dataSource;
@property (retain, nonatomic) NSDate *date;
@property (retain) Reservation *selectedReservation;
- (void) refreshTotals;
- (id)initWithFrame:(CGRect)frame delegate: (id) delegate;

- (void) showHeader;
- (void) hideHeader;

@end
