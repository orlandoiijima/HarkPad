//
//  CalendarViewController.h
//  HarkPad
//
//  Created by Willem Bison on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



#import "CalendarMonthView.h"
#import "SelectItemDelegate.h"

@interface CalendarViewController : UIViewController <CalendarViewDelegate>

@property (retain) id<SelectItemDelegate> delegate;

- (void) gotoDate: (NSDate *)date;

@end
