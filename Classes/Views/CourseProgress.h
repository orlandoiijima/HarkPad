//
//  CourseProgress.h
//  HarkPad2
//
//  Created by Willem Bison on 30-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"


@protocol ProgressDelegate <NSObject>
- (void)didTapCourse: (NSUInteger)courseOffset;
- (BOOL)canSelectCourse: (NSUInteger)courseOffset;
- (void)didSelectCourse: (NSUInteger)courseOffset;
@optional
@end

@interface CourseProgress : UIView <UIGestureRecognizerDelegate> {
    int countCourses;
    int currentCourse;
    int selectedCourse;
    id<ProgressDelegate> __strong delegate;
}

+ (CourseProgress *) progressWithFrame: (CGRect) frame countCourses: (int)countCourses currentCourseOffset: (int)currentCourseOffset currentCourseState: (CourseState) currentCourseState selectedCourse: (int)selectedCourse orderState:(OrderState)orderState;
- (UIBezierPath *) arcPathForCourse: (NSUInteger) course;
- (void) drawArcForCourse: (NSUInteger)course;
- (int) courseAtPoint: (CGPoint) point;
- (void) fillInnerCircle;

@property (nonatomic) int countCourses;
@property int currentCourse;
@property (nonatomic) int selectedCourse;
@property CourseState currentCourseState;
@property (nonatomic, retain) id<ProgressDelegate> delegate;
@property (retain) UILabel *label;
@property OrderState orderState;

@end
				