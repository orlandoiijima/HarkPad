//
//  Created by wbison on 10-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class CalendarMonthView;


@interface CalendarHeaderView : UIView

@property (retain) UILabel *monthLabel;

+ (CalendarHeaderView *)headerForCalendarView: (CalendarMonthView *)calendarView withFrame: (CGRect) frame;

@end