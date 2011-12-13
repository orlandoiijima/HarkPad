//
//  Created by wbison on 09-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CalendarMonthView.h"
#import "NSDate-Utilities.h"
#import "Product.h"
#import "CalendarDayCell.h"
#import "CalendarHeaderView.h"


@implementation CalendarMonthView {

}

@synthesize selectedDate = _selectedDate, startYear = _startYear, startMonth = _startMonth, calendarDelegate = _calendarDelegate, countMonths = _countMonths, cellColor = _cellColor, headerColor = _headerColor;

- (void) initCalendarView {
    self.delegate = self;
    self.dataSource = self;
    self.startYear = [[NSDate date] year];
    self.startMonth = [[NSDate date] month];
    self.selectedDate = [NSDate date];
    self.countMonths = 1;
    self.columnWidth = self.bounds.size.width / 7;
    self.backgroundColor = [UIColor whiteColor];
    self.cellPadding = CGSizeMake(-1, -1);
    self.leftHeaderWidth = 0;
    self.topHeaderHeight = 0;
    self.cellColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    self.headerColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initCalendarView];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCalendarView];
    }
    return self;
}

- (void)gridView:(GridView *)gridView didTapCellLine:(GridViewCellLine *)cellLine {
    _selectedDate = [self dateFromCellPath:cellLine.path];
    if([self.calendarDelegate respondsToSelector:@selector(calendarView: didTapDate:)])
        [self.calendarDelegate calendarView:self didTapDate: self.selectedDate];
}

- (void)setSelectedDate: (NSDate *)date
{
    _selectedDate = date;
    if (date == nil) {
        self.selectedCellLine = nil;
    }
    else {
       CalendarDayCell *cell = [self cellForDate:date];
        if (cell == nil)
            return;
        self.selectedCellLine = cell;
    }
}

- (NSUInteger)numberOfRowsInGridView:(GridView *)gridView {
//    NSDate *first = [self firstDateInView];
//    NSDate *last = [[self lastDateInView] dateByAddingDays:1];
//    int days = [first daysBeforeDate:last];
//    return days/7;
    return 6 * _countMonths;
}

- (NSUInteger)numberOfColumnsInGridView:(GridView *)gridView {
    return 7;
}

- (NSUInteger)numberOfLinesInGridView:(GridView *)gridView column:(NSUInteger)column row:(NSUInteger)row {
    return 1;
}

- (GridViewCellLine *)gridView:(GridView *)gridView cellLineForPath:(CellPath *)path {
    NSDate *date = [self dateFromCellPath:path];
    BOOL isActive = [date month] >= self.startMonth && [date month] < self.startMonth + self.countMonths;
    CalendarDayCell *cell = [CalendarDayCell cellWithDate:date isActive:isActive calendarView:self];
    return cell;
}

- (NSUInteger)gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path {
    return (self.bounds.size.height - [self heightForHeader:self]) / [self numberOfRowsInGridView:self];
}

- (UIView *)viewForHeader:(GridView *)gridView {
    return [CalendarHeaderView headerForCalendarView:self withFrame:CGRectMake(0, 0, 100, [self heightForHeader:self])];
}

- (NSUInteger)heightForHeader:(GridView *)gridView {
    return 40;
}

- (NSDate *)dateFromCellPath: (CellPath *)cellPath {
    return [[self firstDateInView] dateByAddingDays:cellPath.column + 7 * cellPath.row];
}

- (NSDate *) firstDateInView
{
    return [[self firstDateInMonth] startOfWeek];
}

- (NSDate *) firstDateInMonth
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear: self.startYear];
    [comps setMonth:self.startMonth];
    [comps setDay:1];
    [comps setHour:12];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSDate *) lastDateInView
{
    return [[self firstDateInView] dateByAddingDays:6*_countMonths*7 - 1];
//    return [[[self lastDateInMonth] startOfWeek] dateByAddingDays:6];
}

- (NSDate *) lastDateInMonth
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear: self.startYear];
    [comps setMonth:self.startMonth + self.countMonths];
    [comps setDay:1];
    [comps setHour:12];
    NSDate *last =  [[NSCalendar currentCalendar] dateFromComponents:comps];
    return [last dateBySubtractingDays:1];
}

- (CalendarDayCell *)cellForDate : (NSDate *)date
{
    for(int week = 0; week < 10; week++) {
        for(int day = 0; day < 7; day++) {
            CalendarDayCell *cell = (CalendarDayCell *)[self cellAtColumn:day row: week];
            if (cell != nil) {
                if ([cell.date isEqualToDateIgnoringTime:date])
                    return cell;
            }
        }
    }
    return nil;
}

@end