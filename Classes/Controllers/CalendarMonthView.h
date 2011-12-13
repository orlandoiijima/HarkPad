//
//  Created by wbison on 09-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "GridView.h"

@class CalendarMonthView;
@class CalendarDayCell;

@protocol CalendarViewDelegate <NSObject>

@optional
- (void) calendarView: (CalendarMonthView *) calendarView didTapDate: (NSDate *)date;
@end

@interface CalendarMonthView : GridView <GridViewDelegate, GridViewDataSource, UIScrollViewDelegate> {
    id<CalendarViewDelegate> __strong _calendarDelegate;
    NSDate *_selectedDate;
    int _startYear;
    int _startMonth;
    int _countMonths;
}
- (NSDate *) firstDateInMonth;
- (NSDate *) firstDateInView;
- (NSDate *) lastDateInView;
- (NSDate *) lastDateInMonth;
- (NSDate *)dateFromCellPath: (CellPath *)cellPath;
- (CalendarDayCell *)cellForDate : (NSDate *)date;

@property int startYear;
@property int startMonth;
@property int countMonths;
@property (retain) NSDate *selectedDate;
@property (retain) id<CalendarViewDelegate> calendarDelegate;
@property (retain) UIColor *cellColor;
@property (retain) UIColor *headerColor;
@end