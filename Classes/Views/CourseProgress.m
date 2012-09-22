//
//  CourseProgress.m
//  HarkPad2
//
//  Created by Willem Bison on 30-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "CourseProgress.h"
#import "Utils.h"
#import "Order.h"


@implementation CourseProgress

@synthesize countCourses, currentCourse, currentCourseState, selectedCourse = _selectedCourse, delegate = _delegate, label, orderState;
@dynamic radius, innerRadius;

+ (CourseProgress *) progressWithFrame: (CGRect) frame countCourses: (int)countCourses currentCourseOffset: (int)currentCourseOffset currentCourseState: (CourseState) currentCourseState selectedCourse: (int)selectedCourse orderState: (OrderState) orderState {
    CourseProgress *progress = [[CourseProgress alloc] initWithFrame:frame];
    progress.countCourses = countCourses;
    progress.currentCourse = currentCourseOffset;
    progress.selectedCourse = selectedCourse;
    progress.backgroundColor = [UIColor clearColor];
    progress.orderState = orderState;
    progress.label = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - frame.size.width/4)/2, (frame.size.height - frame.size.height/3)/2, frame.size.width/4, frame.size.height/3)];
    progress.label.autoresizingMask = (UIViewAutoresizing) -1;
    progress.label.text = [Utils getCourseChar: selectedCourse];
    progress.label.textAlignment = NSTextAlignmentCenter;
    progress.label.backgroundColor = [UIColor clearColor];
    progress.label.shadowColor = [UIColor lightTextColor];
    progress.label.font = [UIFont systemFontOfSize: 64];
    progress.label.adjustsFontSizeToFitWidth = YES;
    [progress addSubview:progress.label];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:progress action:@selector(tap:)];
    tapper.delegate = progress;
    [progress addGestureRecognizer:tapper];

    return progress;
}

- (CGFloat) innerRadius
{
    return self.radius / 2;
}

- (CGFloat) radius
{
    return self.bounds.size.height/2 * 0.8;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    int tappedCourse = [self courseAtPoint:[touch locationInView:self]];
    if (tappedCourse == -1) return NO;
    if([_delegate respondsToSelector:@selector(canSelectCourse:)] == false)
        return NO;
    if ([_delegate canSelectCourse: tappedCourse] == YES)
        return YES;
    return NO;
}

- (int) courseAtPoint: (CGPoint) point{
    for(NSUInteger course = 0; course < countCourses; course++) {
        UIBezierPath *arcPath = [self arcPathForCourse:course];
        if ([arcPath containsPoint:point]) {
            return course;
        }
    }
    return -1;
}

- (void) tap: (UITapGestureRecognizer *)tapper
{
    int tappedCourse = -1;
    for(NSUInteger course = 0; course < countCourses; course++) {
        UIBezierPath *arcPath = [self arcPathForCourse:course];
        if ([arcPath containsPoint:[tapper locationInView:self]]) {
            tappedCourse = course;
            break;
        }
    }

    if (tappedCourse == -1)
        return;

    if([_delegate respondsToSelector:@selector(didTapCourse:)])
        [_delegate didTapCourse: tappedCourse];

    BOOL canSelect = NO;
    if([_delegate respondsToSelector:@selector(canSelectCourse:)])
        if ([_delegate canSelectCourse: tappedCourse] == YES)
            canSelect = YES;

    if (canSelect) {
        self.selectedCourse = tappedCourse;
//        [self setNeedsDisplay];

        if([_delegate respondsToSelector:@selector(didSelectCourse:)])
            [_delegate didSelectCourse: tappedCourse];
    }
}

- (void)drawRect:(CGRect)rect {
    if(countCourses == 0) return;
    for(int course = countCourses - 1; course >= 0; course--)
    {
        [self drawArcForCourse: (NSUInteger)course];
    }

    if (orderState == OrderStateBilled || orderState == OrderStatePaid)
        [self fillInnerCircle];
}

- (void) drawArcForCourse: (NSUInteger)course
{
    UIColor *fillColor;
    if(course > currentCourse || currentCourse == -1)
        fillColor = [UIColor whiteColor];
    else
    if(course < currentCourse)
        fillColor = [UIColor greenColor];
    else
    {
        switch(currentCourseState)
        {
            case CourseStateServed:
                fillColor = [UIColor greenColor];
                break;
            case CourseStateRequested:
                fillColor = [UIColor colorWithRed:1 green:0.7 blue:0 alpha:1];
                break;
            case CourseStateRequestedOverdue:
                fillColor = [UIColor redColor];
                break;
            case CourseStateNothing:
                fillColor = [UIColor whiteColor];
                break;
        }
    }
    UIColor *strokeColor = [UIColor lightGrayColor];

    UIBezierPath *path = [self arcPathForCourse: course];
    
    [strokeColor setStroke];
    [fillColor setFill];

    path.lineWidth = 1; //course == selectedCourse ?  : 0;

    [path fill];
    [path stroke];
}

- (UIBezierPath *) arcPathForCourse: (NSUInteger) course
{
    float startAngle = (course * 2 * 3.14159f) / countCourses - 3.14159/2;
    float endAngle = ((course + 1) * 2 * 3.14159f) / countCourses - 3.14159/2;

    UIBezierPath *path = [UIBezierPath bezierPath];

    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    CGFloat thisRadius = self.radius;
    if(course == _selectedCourse) {
        thisRadius *= 1.1;
    }
    [path addArcWithCenter:center radius: thisRadius startAngle:startAngle endAngle:endAngle clockwise:1];
    [path addArcWithCenter:center radius: self.innerRadius startAngle:endAngle endAngle:startAngle clockwise:0];

    [path closePath];


    return path;
}

- (void) fillInnerCircle
{
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius: self.innerRadius startAngle:0 endAngle: 2*M_PI clockwise:0];
    [[UIColor redColor] setFill];
    [[UIColor whiteColor] setStroke];
    path.lineWidth = 3;
    [path stroke];
    [path fill];
}

- (void)setSelectedCourse: (int) newCourse {
    _selectedCourse = newCourse;
    label.text = newCourse == -1 ? @"" : [Utils getCourseChar: newCourse];
    [self setNeedsDisplay];
}

- (void)setCountCourses: (int) count {
    countCourses = count;
    [self setNeedsDisplay];
}


@end
