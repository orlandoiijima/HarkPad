//
//  CourseProgress.h
//  HarkPad2
//
//  Created by Willem Bison on 30-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CourseState { Served, Requested, RequestedOverdue } CourseState;

@protocol ProgressDelegate <NSObject>
- (void)didTapCourse: (NSUInteger)courseOffset;
@optional
@end

@interface CourseProgress : UIView <UIGestureRecognizerDelegate> {
    int countCourses;
    int currentCourse;
    int selectedCourse;
    BOOL isCurrentCourseHot;
    id<ProgressDelegate> __strong delegate;
}

+ (CourseProgress *) progressWithFrame: (CGRect) frame countCourses: (int)countCourses currentCourse: (int) currentCourse selectedCourse: (int)selectedCourse;
- (UIBezierPath *) arcPathForCourse: (NSUInteger) course;
- (void) drawArcForCourse: (NSUInteger)course;

@property int countCourses;
@property int currentCourse;
@property int selectedCourse;
@property CourseState currentCourseState;
@property (nonatomic, retain) id<ProgressDelegate> delegate;
@property (retain) UILabel *label;

@end
				