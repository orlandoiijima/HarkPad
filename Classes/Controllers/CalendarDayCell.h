//
//  Created by wbison on 09-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "GridViewCellLine.h"
#import "DayReservationsInfo.h"
#import "CalendarMonthView.h"


@interface CalendarDayCell : GridViewCellLine {
    UIView *lunchStatusView;
    UIView *dinnerStatusView;
    BOOL isActive;
    NSDate *date;
    UILabel *label;
}


@property BOOL isActive;
@property (retain) NSDate *date;
@property (retain) UILabel *label;
@property (retain) CalendarMonthView *calendarView;
@property (retain) UIView *lunchStatusView;
@property (retain) UIView *dinnerStatusView;
@property SlotStatus lunchStatus;
@property SlotStatus dinnerStatus;

+ (CalendarDayCell *) cellWithDate: (NSDate *)date isActive: (BOOL) isActive calendarView: (CalendarMonthView *)calendarView;

- (void) setColorForView: (UIView *)view byStatus: (SlotStatus) status;

@end