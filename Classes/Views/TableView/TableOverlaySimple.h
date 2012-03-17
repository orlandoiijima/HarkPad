//
//  TableOverlaySimple.h
//  HarkPad
//
//  Created by Willem Bison on 02/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseProgress.h"

@interface TableOverlaySimple : UIView

@property (retain) CourseProgress *courseProgressView;
@property int selectedCourseOffset;
@property int countCourses;

- (id)initWithFrame:(CGRect)frame tableName: (NSString *)name countCourses: (int)countCourses currentCourseOffset: (int)currentCourseOffset selectedCourse: (int)selectedCourse currentCourseState: (CourseState) currentCourseState orderState:(OrderState)orderState delegate: (id<NSObject>) delegate;

@end
