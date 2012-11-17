//
//  Created by wbison on 09-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CalendarDayCell.h"
#import "NSDate-Utilities.h"
#import "Logger.h"
#import <QuartzCore/QuartzCore.h>

@implementation CalendarDayCell {

}

@synthesize isSelected = _isSelected, label = _label;
@synthesize lunchStatusView = _lunchStatusView;
@synthesize dinnerStatusView = _dinnerStatusView;
@synthesize lunchStatus = _lunchStatus;
@synthesize dinnerStatus = _dinnerStatus;
@synthesize isActive = _isActive;
@synthesize date = _date;
@synthesize calendarView = _calendarView;


+ (CalendarDayCell *) cellWithDate: (NSDate *)date isActive: (BOOL) isActive calendarView: (CalendarMonthView *)calendarView
{
    CalendarDayCell *cell = [[CalendarDayCell alloc] init];
    cell.calendarView = calendarView;
    cell.date = date;
    cell.isActive = isActive;
    cell.backgroundColor = calendarView.cellColor;
    cell.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    cell.label.text = [NSString stringWithFormat:@"%d", [date day]];
    cell.label.backgroundColor = [UIColor clearColor];
    cell.label.textColor = isActive ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.label.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:cell.label];

    NSArray *colors = [NSArray arrayWithObjects:
                           (__bridge id)[UIColor colorWithWhite:1.0f alpha:0.9f].CGColor,
                           (__bridge id)[UIColor colorWithWhite:1.0f alpha:0.7f].CGColor,
                           (__bridge id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                           (__bridge id)[UIColor colorWithWhite:0.7f alpha:0.2f].CGColor,
                           (__bridge id)[UIColor colorWithWhite:0.3f alpha:0.0f].CGColor,
                           nil];
    NSArray *locations = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.2f],
                              [NSNumber numberWithFloat:0.5f],
                              [NSNumber numberWithFloat:0.8f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];

    cell.lunchStatusView = [[UILabel alloc] init];
    [cell setupStatusView:cell.lunchStatusView colors:colors locations:locations];

    cell.dinnerStatusView = [[UILabel alloc] init];
    [cell setupStatusView:cell.dinnerStatusView colors:colors locations:locations];

    cell.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    cell.layer.borderWidth = 0.5;

    cell.isSelected = NO;
    
    return cell;
}

- (void)setupStatusView: (UILabel *)statusView colors: (NSArray *)colors locations: (NSArray *)locations
{
    statusView.textAlignment = NSTextAlignmentCenter;
    statusView.font = [UIFont systemFontOfSize:12];
    statusView.adjustsFontSizeToFitWidth = YES;
    statusView.alpha = 0;
    [self addSubview:statusView];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.locations = locations;
    gradientLayer.colors = colors;
    [statusView.layer insertSublayer:gradientLayer atIndex:0];

}

- (void) layoutSubviews
{
    self.label.frame = CGRectMake(0, 0, self.bounds.size.width, 20);

    float topMargin = self.label.frame.origin.y + self.label.frame.size.height;
    float bottomMargin = 2;
    float leftMargin = 2;
    float rightMargin = 2;
    float betweenMargin = 2;

    float itemHeight = self.frame.size.height - topMargin - bottomMargin;
    float itemWidth = (self.frame.size.width - leftMargin - rightMargin - betweenMargin) / 2;
    self.lunchStatusView.frame = CGRectIntegral(CGRectMake(leftMargin, topMargin, itemWidth, itemHeight));
    self.dinnerStatusView.frame = CGRectIntegral(CGRectMake(leftMargin + itemWidth + betweenMargin, topMargin, itemWidth, itemHeight));

    CAGradientLayer *layer = [self.dinnerStatusView.layer.sublayers objectAtIndex:0];
    layer.frame = self.dinnerStatusView.bounds;

    layer = [self.lunchStatusView.layer.sublayers objectAtIndex:0];
    layer.frame = self.dinnerStatusView.bounds;
}

- (void) setIsSelected: (BOOL)newIsSelected
{
    if (_isActive == false) {

    }
    else
    if (newIsSelected) {
        self.backgroundColor = [UIColor blueColor];
        self.label.textColor = [UIColor whiteColor];
    }
    else {
        self.backgroundColor = [self.date isToday] ? [UIColor greenColor] : [self.calendarView cellColor];
        self.label.textColor = self.isActive ? [UIColor blackColor] : [UIColor grayColor];
    }
}

- (void) setInfo: (DayReservationsInfo *)info
{
    _lunchStatus = info.lunchStatus;
    _lunchStatusView.text = info.lunchCount == 0 ? @"" : [NSString stringWithFormat:@"%d", info.lunchCount];
    [self setColorForView:_lunchStatusView byStatus: _lunchStatus];

    _dinnerStatus = info.dinnerStatus;
    _dinnerStatusView.text = info.dinnerCount == 0 ? @"" : [NSString stringWithFormat:@"%d", info.dinnerCount];
    [self setColorForView:_dinnerStatusView byStatus: _dinnerStatus];
    [Logger info:_dinnerStatusView.text];
}


- (void) setColorForView: (UILabel *)view byStatus: (SlotStatus) status
{
    [UIView animateWithDuration:0.6f animations: ^{
    switch(status)
    {
        case statusFull:
            view.alpha = 1;
            view.backgroundColor = [UIColor redColor];
            view.textColor = [UIColor whiteColor];
            break;
        case statusNothing:
            view.alpha = 1;
            view.backgroundColor = [UIColor whiteColor];
            break;
        case statusClosed:
            view.alpha = 0;
            view.backgroundColor = [UIColor whiteColor];
            break;
        case statusAvailable:

            view.alpha = 1;
            view.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.4 alpha:1];
            view.textColor = [UIColor blackColor];
            break;
    }}];
}
@end