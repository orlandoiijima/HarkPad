//
//  ReservationsSimple.h
//  HarkPad
//
//  Created by Willem Bison on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReservationDayView.h"
#import "SelectItemDelegate.h"

@interface ReservationsSimple : UIViewController <SelectItemDelegate>

@property (assign, nonatomic) ReservationDayView *dayView;

- (void) gotoDate: (NSDate *)date;

@end
