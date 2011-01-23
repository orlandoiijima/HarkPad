//
//  TableButton.h
//  HarkPad
//
//  Created by Willem Bison on 17-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved
//

#import <UIKit/UIKit.h>
#import "Table.h"
#import "OrderInfo.h"
#import "CourseProgress.h"
#import <QuartzCore/QuartzCore.h>

@interface TableButton : UIButton {
}

@property (retain) UILabel *name;
@property (retain) Table *table;
@property (retain) OrderInfo *orderInfo;
@property (retain) CourseProgress * progress;
@property float unit;

+ (TableButton*) buttonWithTable: (Table*)table offset: (CGPoint)offset scaleX: (float)scaleX scaleY:(float)scaleY;

- (void) drawSeat: (CGContextRef)context withBounds: (CGRect) bounds isOccupied: (BOOL) isOccupied;
- (void) drawProductSymbol: (CGContextRef)context withBounds: (CGRect) bounds product: (Product*) product;

//- (void) drawCourseProgress: (CGContextRef) context inRect: (CGRect) rect;
//- (void) drawArc: (CGContextRef) context inRect: (CGRect) rect startAngle: (float) startAngle endAngle: (float) endAngle strokeColor: (UIColor *) strokeColor strokeWidth: (float) strokeWidth fillColor: (UIColor *)fillColor;

@end
