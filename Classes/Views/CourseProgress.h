//
//  CourseProgress.h
//  HarkPad2
//
//  Created by Willem Bison on 30-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseProgress : UIView {
}

+ (CourseProgress *) progressWithFrame: (CGRect) frame countCourses: (int)countCourses currentCourse: (int) currentCourse;
- (void) drawArc: (CGContextRef) context inRect: (CGRect) rect startAngle: (float) startAngle endAngle: (float) endAngle strokeColor: (UIColor *) strokeColor strokeWidth: (float) strokeWidth fillColor: (UIColor *)fillColor;
                                                                                                                                                                                                                                          
@property int countCourses;
@property int currentCourse;
@property BOOL isCurrentCourseHot; 
@end
				