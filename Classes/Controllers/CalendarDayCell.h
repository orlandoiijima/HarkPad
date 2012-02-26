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
    UILabel *_lunchStatusView;
    UILabel *_dinnerStatusView;
    BOOL isActive;
    NSDate *date;
    UILabel *label;
    SlotStatus _lunchStatus;
    SlotStatus _dinnerStatus;
}


@property BOOL isActive;
@property (retain) NSDate *date;
@property (retain) UILabel *label;
@property (retain) CalendarMonthView *calendarView;
@property (retain) UILabel *lunchStatusView;
@property (retain) UILabel *dinnerStatusView;
@property (nonatomic) SlotStatus lunchStatus;
@property (nonatomic) SlotStatus dinnerStatus;

+ (CalendarDayCell *) cellWithDate: (NSDate *)date isActive: (BOOL) isActive calendarView: (CalendarMonthView *)calendarView;

- (void) setColorForView: (UIView *)view byStatus: (SlotStatus) status;
- (void) setInfo: (DayReservationsInfo *)info;
- (void)setupStatusView: (UILabel *)statusView colors: (NSArray *)colors locations: (NSArray *)locations;

@end