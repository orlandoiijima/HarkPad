//
//  TableOverlaySimple.m
//  HarkPad
//
//  Created by Willem Bison on 02/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "TableOverlaySimple.h"
#import "CourseProgress.h"

@implementation TableOverlaySimple

@synthesize courseProgressView;

- (id)initWithFrame:(CGRect)frame tableName: (NSString *)name countCourses: (int)countCourses currentCourseOffset: (int)currentCourseOffset selectedCourse: (int)selectedCourse currentCourseState: (CourseState) currentCourseState orderState: (OrderState) orderState
{
    self = [super initWithFrame:frame];
    if (self) {

        self.autoresizingMask = (UIViewAutoresizing)-1;

        CGRect progressRect;
        CGFloat progressSize;
        if (frame.size.width > frame.size.height)
            progressSize = frame.size.height;
        else
            progressSize = frame.size.width;

        progressRect = CGRectMake( (frame.size.width - progressSize)/2, (frame.size.height - progressSize)/2, progressSize, progressSize);
        courseProgressView = [CourseProgress progressWithFrame: progressRect countCourses:countCourses currentCourseOffset:currentCourseOffset currentCourseState:currentCourseState selectedCourse:selectedCourse orderState:(OrderState)orderState];
        [self addSubview:courseProgressView];
        courseProgressView.autoresizingMask = (UIViewAutoresizing)-1;
        courseProgressView.currentCourseState = currentCourseState;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, frame.size.width - 5, 16)];
        label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview: label];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor whiteColor];
        label.text = name;
        label.font = [UIFont systemFontOfSize: 18];
        label.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

@end
