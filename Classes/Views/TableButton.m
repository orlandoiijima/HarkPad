//
//  TableButton.m
//  HarkPad
//
//  Created by Willem Bison on 17-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TableButton.h"
#import "Table.h"
#import "CourseProgress.h"
#import "Utils.h" 

@implementation TableButton

@synthesize table, orderInfo, progress, name, time, time2;

+ (TableButton*) buttonWithTable: (Table*)table offset: (CGPoint)offset scaleX: (float)scaleX scaleY:(float)scaleY
{
    TableButton *button = [[[TableButton alloc] init] autorelease];
    button.table = table;
    button.orderInfo = nil;
    button.frame =  CGRectMake(
                               (table.bounds.origin.x * scaleX) - offset.x,
                               (table.bounds.origin.y * scaleY) - offset.y,
                               table.bounds.size.width * scaleX,
                               table.bounds.size.height * scaleY);
    button.center = CGPointMake(CGRectGetMidX(button.frame), CGRectGetMidY(button.frame)); 
    button.tag = table.id;
    
    CGRect frame = CGRectMake(button.unit/2, button.frame.size.height/4, button.frame.size.width - button.unit, button.unit);
    button.name = [[UILabel alloc] initWithFrame:frame];
    button.name.font = [UIFont systemFontOfSize:20];
    button.name.shadowColor = [UIColor grayColor];
    button.name.adjustsFontSizeToFitWidth = YES;
    button.name.textAlignment = UITextAlignmentCenter;
    button.name.backgroundColor = [UIColor clearColor];
    button.name.textColor = [UIColor blackColor];
    button.name.text = table.name;
    [button addSubview:button.name];
    
    if(button.frame.size.width >= button.frame.size.height)
        frame = CGRectMake(button.unit/2, button.name.frame.origin.y + button.name.frame.size.height, (button.frame.size.width - button.unit)/2, button.unit);
    else    
        frame = CGRectMake(button.unit/2, button.name.frame.origin.y + button.name.frame.size.height, button.frame.size.width - button.unit, button.unit);
    
    button.time = [[UILabel alloc] initWithFrame:frame];
    button.time.adjustsFontSizeToFitWidth = YES;
    button.time.textAlignment = UITextAlignmentCenter;
    button.time.backgroundColor = [UIColor clearColor];
    button.time.textColor = [UIColor blueColor];
    button.time.text = @"";
    [button addSubview:button.time];

    if(button.frame.size.width >= button.frame.size.height)
        frame = CGRectMake(button.frame.size.width/2, button.name.frame.origin.y + button.name.frame.size.height, button.time.frame.size.width, button.time.frame.size.height);
    else
        frame = CGRectMake(button.unit/2, button.time.frame.origin.y + button.time.frame.size.height, button.time.frame.size.width, button.time.frame.size.height);
    button.time2 = [[UILabel alloc] initWithFrame:frame];
    button.time2.adjustsFontSizeToFitWidth = YES;
    button.time2.textAlignment = UITextAlignmentCenter;
    button.time2.backgroundColor = [UIColor clearColor];
    button.time2.textColor = [UIColor blueColor];
    button.time2.text = @"";
    [button addSubview:button.time2];
    
    
    frame = CGRectMake(button.frame.size.width - button.unit, 0, button.unit, button.unit);
    button.progress = [CourseProgress progressWithFrame:frame countCourses:0 currentCourse:0];
    [button addSubview:button.progress];
        
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectInset(button.bounds, button.unit/2, button.unit/2);
    gradient.cornerRadius = 4;
    gradient.borderColor = [[UIColor grayColor] CGColor];
    gradient.borderWidth = 1;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];		
    [button.layer insertSublayer:gradient atIndex:0];        
    return button;
}

- (float) unit
{
    if(table == nil)
        return 0;
    int countSeatRow = table.countSeats / 2;

    if(self.bounds.size.width >= self.bounds.size.height)
        return self.bounds.size.width / (countSeatRow * 3 + 1);
    else
        return self.bounds.size.height / (countSeatRow * 3 + 1);
}

- (void) setOrderInfo:(OrderInfo *)info
{
    CAGradientLayer *gradient = [self.layer.sublayers objectAtIndex:0];
    if(info != orderInfo) {
        [orderInfo release];
        orderInfo = [info retain];
        if(orderInfo != nil)
        {
            time.text = [Utils getElapsedMinutesString:orderInfo.createdOn];
            if(orderInfo.currentCourseRequestedOn != nil)
            {
                time2.text = [Utils getElapsedMinutesString:orderInfo.currentCourseRequestedOn];
            }
            else
                time2.text = @"";
            progress.countCourses = orderInfo.countCourses;
            progress.currentCourse = orderInfo.currentCourse;
            if(orderInfo.state == ordering)
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.6 green:0.6 blue:0.9 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
            else
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.9 green:0.6 blue:0.6 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
        }
        else
        {
            time.text = @"";
            time2.text = @"";
            progress.countCourses = 0;
            progress.currentCourse = 0;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
        }
        [self setNeedsDisplay];
        [progress setNeedsDisplay];
    }
}

- (void)drawRect : (CGRect) dirtyRect {
    CGContextRef ctf = UIGraphicsGetCurrentContext();

    int countSeatRow = table.countSeats / 2;
    float seatMargin = self.unit / 2;
    float seatWidth = self.unit * 2;

    CGRect tableRect = self.bounds;
    tableRect = CGRectInset([self bounds], seatMargin, seatMargin);
    
//    CGContextStrokeRect(ctf, <#CGRect rect#>)
    
    int countSeatRowOpposite = table.countSeats - countSeatRow;
    
    if(tableRect.size.width >= tableRect.size.height)
    {
        float left = self.unit;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            bool isOccupied = self.orderInfo != nil && [self.orderInfo isSeatOccupied:seat]; 
            CGRect rect = CGRectMake(left, tableRect.origin.y - seatMargin, seatWidth, seatMargin / 2);
            [self drawSeat: ctf withBounds: rect isOccupied: isOccupied];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(left, tableRect.origin.y + tableRect.size.height + seatMargin / 2, seatWidth, seatMargin / 2);
                isOccupied = self.orderInfo != nil && [self.orderInfo isSeatOccupied:seat]; 
                [self drawSeat: ctf withBounds: rect isOccupied: isOccupied];
            }
            left += seatWidth + self.unit;
        }
    }
    else
    {
        float top = self.unit;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            bool isOccupied = self.orderInfo != nil && [self.orderInfo isSeatOccupied:seat]; 
            CGRect rect = CGRectMake(tableRect.origin.x - seatMargin, top, seatMargin / 2, seatWidth);
            [self drawSeat: ctf withBounds: rect isOccupied: isOccupied];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(tableRect.origin.x + tableRect.size.width + seatMargin / 2, top, seatMargin / 2, seatWidth);
                isOccupied = self.orderInfo != nil && [self.orderInfo isSeatOccupied:seat]; 
                [self drawSeat: ctf withBounds: rect isOccupied: isOccupied];
            }
            top += seatWidth + self.unit;
        }
    }
}

- (void) drawSeat: (CGContextRef)context withBounds: (CGRect) bounds isOccupied: (BOOL) isOccupied
{
    UIColor * backgroundColor;
    if(isOccupied) backgroundColor = [UIColor blackColor];
    else backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.2];
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, bounds);    
}

- (void)dealloc {
    [super dealloc];
}


@end
