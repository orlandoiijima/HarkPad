//
//  Created by wbison on 09-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CalendarDayCell.h"
#import "NSDate-Utilities.h"
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
    cell.label.textColor = isActive ? [UIColor blackColor] : [UIColor grayColor];
    cell.label.textAlignment = UITextAlignmentCenter;
    [cell addSubview:cell.label];

    cell.lunchStatusView = [[UIView alloc] init];
    cell.lunchStatusView.alpha = 0;
    [cell addSubview:cell.lunchStatusView];

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
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.locations = locations;
    gradientLayer.colors = colors;
    [cell.lunchStatusView.layer insertSublayer:gradientLayer atIndex:0];

    cell.dinnerStatusView = [[UIView alloc] init];
    cell.dinnerStatusView.alpha = 0;
    [cell addSubview:cell.dinnerStatusView];

    gradientLayer = [CAGradientLayer layer];
    gradientLayer.locations = locations;
    gradientLayer.colors = colors;
    [cell.dinnerStatusView.layer insertSublayer:gradientLayer atIndex:0];

    cell.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    cell.layer.borderWidth = 0.5;

    cell.isSelected = NO;
    
    return cell;
}

- (void) layoutSubviews
{
    self.label.frame = CGRectMake(0, 0, self.bounds.size.width, 20);

    float topMargin = self.label.frame.origin.y + self.label.frame.size.height;
    float bottomMargin = 5;
    float leftMargin = 5;
    float rightMargin = 5;
    float betweenMargin = 4;

    float itemHeight = self.frame.size.height - topMargin - bottomMargin;
    float itemWidth = (self.frame.size.width - leftMargin - rightMargin - betweenMargin) / 2;
    self.lunchStatusView.frame = CGRectMake(leftMargin, topMargin, itemWidth, itemHeight);
    self.dinnerStatusView.frame = CGRectMake(leftMargin + itemWidth + betweenMargin, topMargin, itemWidth, itemHeight);

    CAGradientLayer *layer = [self.dinnerStatusView.layer.sublayers objectAtIndex:0];
    layer.frame = self.dinnerStatusView.bounds;

    layer = [self.lunchStatusView.layer.sublayers objectAtIndex:0];
    layer.frame = self.dinnerStatusView.bounds;
}

- (void) setIsSelected: (BOOL)isSelected
{
    if (_isActive == false) {

    }
    else
    if (isSelected) {
        self.backgroundColor = [UIColor blueColor];
        self.label.textColor = [UIColor whiteColor];
    }
    else {
        self.backgroundColor = [self.date isToday] ? [UIColor greenColor] : [self.calendarView cellColor];
        self.label.textColor = self.isActive ? [UIColor blackColor] : [UIColor grayColor];
    }
}

- (void) setLunchStatus: (SlotStatus)value
{
    _lunchStatus = value;
    [self setColorForView:self.lunchStatusView byStatus:value];
}

- (void) setDinnerStatus: (SlotStatus)value
{
    _dinnerStatus = value;
    [self setColorForView:self.dinnerStatusView byStatus:value];
}

- (void) setColorForView: (UIView *)view byStatus: (SlotStatus) status
{
    CAGradientLayer *layer = [view.layer.sublayers objectAtIndex:0];
    [UIView animateWithDuration:0.6f animations: ^{
    switch(status)
    {
        case statusFull:
            view.alpha = 1;
            view.backgroundColor = [UIColor redColor];
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
            break;
    }}];
}
@end