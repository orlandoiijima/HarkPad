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
#import "SeatInfo.h"
#import "CourseProgress.h"
#import <QuartzCore/QuartzCore.h>

@interface TableButton : UIButton {
    UILabel *name;
    Table *table;
    OrderInfo *orderInfo;
    CourseProgress * progress;
    float unit;
    float widthPerPerson, tableLeftMargin, tableTopMargin, seatWidth, seatHeight, symbolWidth;
}

@property (retain) UILabel *name;
@property (retain) Table *table;
@property (retain) OrderInfo *orderInfo;
@property (retain) CourseProgress * progress;
@property (retain) UIImageView *flag;
@property float unit, widthPerPerson, tableLeftMargin, tableTopMargin, seatWidth, seatHeight, symbolWidth;

+ (TableButton*) buttonWithTable: (Table*)table offset: (CGPoint)offset scaleX: (float)scaleX scaleY:(float)scaleY;
- (void) drawSeat: (CGContextRef)context withBounds: (CGRect) bounds info: (SeatInfo *) seatInfo;

@end
