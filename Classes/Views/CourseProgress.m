//
//  CourseProgress.m
//  HarkPad2
//
//  Created by Willem Bison on 30-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "CourseProgress.h"


@implementation CourseProgress

@synthesize countCourses, currentCourse, isCurrentCourseHot;

+ (CourseProgress *) progressWithFrame: (CGRect) frame countCourses: (int)countCourses currentCourse: (int) currentCourse {
    CourseProgress *progress = [[CourseProgress alloc] initWithFrame:frame]; 
    progress.countCourses = countCourses;
    progress.currentCourse = currentCourse;
    progress.backgroundColor = [UIColor clearColor];
    progress.userInteractionEnabled = false;
    return progress;
}

- (void)drawRect:(CGRect)rect {
    if(countCourses == 0) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    rect = self.bounds;
    for(int course = countCourses - 1; course >= 0; course--)
    {
        float startAngle = (course * 2 * 3.14159f) / countCourses - 3.14159/2;
        float endAngle = ((course + 1) * 2 * 3.14159f) / countCourses - 3.14159/2;
        UIColor *fillColor;
        if(course > currentCourse)
            fillColor = [UIColor whiteColor];
        else
        if(course < currentCourse)
            fillColor = [UIColor greenColor];
        else
            fillColor = isCurrentCourseHot ? [UIColor redColor] : [UIColor greenColor];
        UIColor *strokeColor = course <= currentCourse ? [UIColor blackColor] : [UIColor grayColor];
        [self drawArc: context inRect: rect startAngle: startAngle endAngle: endAngle strokeColor: strokeColor strokeWidth: 1.0f fillColor: fillColor];
    }
}

- (void) drawArc: (CGContextRef) context inRect: (CGRect) rect startAngle: (float) startAngle endAngle: (float) endAngle strokeColor: (UIColor *) strokeColor strokeWidth: (float) strokeWidth fillColor: (UIColor *)fillColor
{
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, strokeWidth);
    
    float radius = rect.size.height/2 * 0.9;
    CGPoint center = CGPointMake(rect.size.width/2.0f, rect.size.height/2.0f);
//    if(exploded) {
//        center.x += radius/4 * cosf(startAngle + (endAngle - startAngle)/2) ;	
//        center.y += radius/4 * sinf(startAngle + (endAngle - startAngle)/2) ;	
//    }
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}


- (void)dealloc {
    [super dealloc];
}


@end
