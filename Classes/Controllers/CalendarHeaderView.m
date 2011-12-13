//
//  Created by wbison on 10-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <mach/mig_errors.h>
#import "CalendarHeaderView.h"
#import "NSDate-Utilities.h"
#import "CalendarMonthView.h"


@implementation CalendarHeaderView {

}

@synthesize monthLabel = _monthLabel;

+ (CalendarHeaderView *)headerForCalendarView: (CalendarMonthView *)calendarView withFrame: (CGRect) frame
{
    CalendarHeaderView *headerView = [[CalendarHeaderView alloc] initWithFrame:frame];
    headerView.backgroundColor = calendarView.headerColor;

    headerView.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 15)];
    [headerView addSubview: headerView.monthLabel];
    headerView.monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.monthLabel.backgroundColor = [UIColor clearColor];
    headerView.monthLabel.textAlignment = UITextAlignmentCenter;
    NSDate *date = [calendarView firstDateInMonth];
    headerView.monthLabel.text = [date monthString];

    date = [date startOfWeek];
    float height = 15;
    float x = 0;
    for(int day=0; day < 7; day++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, frame.size.height - height, calendarView.columnWidth, height)];
        [headerView addSubview:label];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor grayColor];
        label.adjustsFontSizeToFitWidth = true;
        label.text = [[[date weekdayString] substringToIndex:2] uppercaseString];
        date = [date dateByAddingDays:1];
        x += calendarView.columnWidth;
    }

    headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    headerView.layer.borderWidth = 1;

    return headerView;
}

@end