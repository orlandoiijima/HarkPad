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
}

@property (retain) NSMutableDictionary *countLabels;
@property (retain) UITableView *table;
@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) IBOutlet UILabel *dayLabel;
@property (retain) ReservationDataSource *dataSource;

- (Reservation *) selectedReservation;
- (void) refreshTotals: (ReservationDataSource *)dataSource;
- (id)initWithFrame:(CGRect)frame delegate: (id) delegate;

@end
