//
//  Tableself.m
//  HarkPad
//
//  Created by Willem Bison on 17-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TableButton.h"
#import "Table.h"
#import "CourseProgress.h"
#import "Utils.h" 
#import "ProductSymbol.h"

@implementation TableButton

@synthesize table, orderInfo, progress, name, unit, flag, tableLeftMargin, tableTopMargin, widthPerPerson, seatWidth, seatHeight, symbolWidth, tableWidth, tableDepth, seatMargin;


+ (TableButton*) buttonWithTable: (Table*)table offset: (CGPoint)offset scaleX: (float)scaleX scaleY:(float)scaleY
{
    TableButton *button =  [[TableButton alloc] init];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.cornerRadius = 4;
    gradientLayer.borderColor = [[UIColor grayColor] CGColor];
    gradientLayer.borderWidth = 1;
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];		
    [button.layer insertSublayer:gradientLayer atIndex:0];        
    
    [button setupByTable:table offset:offset scaleX:scaleX];
    return button;
}

- (void) setupByTable: (Table *) newTable offset: (CGPoint) offset scaleX: (float)scaleX
{
    self.table = newTable;
    self.orderInfo = nil;
    self.frame = CGRectMake(
                            (newTable.bounds.origin.x - offset.x) * scaleX,
                            (newTable.bounds.origin.y - offset.y) * scaleX,
                            newTable.bounds.size.width * scaleX,
                            newTable.bounds.size.height * scaleX);
    if(table.seatOrientation == row)
    {
        tableTopMargin = self.bounds.size.height / 6;
    }
    else
    {
        tableTopMargin = self.bounds.size.width / 12;
    }
    
    if(table.seatOrientation == row)
    {
        tableLeftMargin = self.bounds.size.height / 12;
    }
    else
    {
        tableLeftMargin = self.bounds.size.width / 6;
    }
    
    if(table.seatOrientation == row)
    {
        tableDepth = self.bounds.size.height - 2 * self.tableTopMargin;
    }
    else
    {
        tableDepth = self.bounds.size.width - 2 * self.tableLeftMargin;   
    }
    
    if(table.seatOrientation == row)
    {
        tableWidth = self.bounds.size.width - 2 * self.tableLeftMargin;
    }
    else
    {
        tableWidth = self.bounds.size.height - 2 * self.tableTopMargin;   
    }
    
    int countSeatRow = table.countSeats / 2;
    widthPerPerson = self.tableWidth / countSeatRow;
    
    seatWidth = (3 * self.widthPerPerson) / 4;
    
    seatMargin = self.seatWidth / 4;
    
    seatHeight = self.widthPerPerson / 6;
    
    
    self.tag = table.id;
    
    if(table.seatOrientation == row)
        self.unit = self.bounds.size.width / (countSeatRow * 3 + 1);
    else
        self.unit = self.bounds.size.height / (countSeatRow * 3 + 1);
    
    self.symbolWidth = self.tableDepth / 2 - 4;
    if(self.seatWidth < self.symbolWidth)
        self.symbolWidth = self.seatWidth; 
    
    CGRect tableRect = CGRectInset(self.bounds, self.tableLeftMargin, self.tableTopMargin);
    
    int countSeatRowOpposite = table.countSeats - countSeatRow;
    
    if(table.seatOrientation == row)
    {
        float left = self.tableLeftMargin + (self.widthPerPerson - self.symbolWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            CGRect rect = CGRectMake(left, tableRect.origin.y + 2, self.symbolWidth, self.symbolWidth);
            ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
            [self addSubview: symbol];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(left, tableRect.origin.y + tableRect.size.height - self.symbolWidth - 4, self.symbolWidth, self.symbolWidth);
                ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
                [self addSubview: symbol];
            }
            
            left += self.widthPerPerson;
        }
    }
    else
    {
        float top = self.tableTopMargin + (self.widthPerPerson - self.seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            CGRect rect = CGRectMake(tableRect.origin.x + self.seatMargin/4, top + self.seatWidth/4, self.seatWidth / 2, self.seatWidth/2);
            ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
            [self addSubview: symbol];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(tableRect.origin.x + tableRect.size.width - self.seatMargin / 4 - self.seatWidth/2, top + self.seatWidth/4, self.seatWidth / 2, self.seatWidth/2);
                ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
                [self addSubview: symbol];
            }
            top += self.widthPerPerson;
        }
        
    }
    
    CGRect frame;
     
    frame = CGRectMake(self.frame.size.width - self.widthPerPerson / 2, 0, self.widthPerPerson / 2, self.widthPerPerson / 2);
    self.progress = [CourseProgress progressWithFrame:frame countCourses:0 currentCourseOffset:0 currentCourseState: CourseStateNothing selectedCourse:-1 orderState:OrderStateOrdering];
    [self addSubview:self.progress];
    
    frame = CGRectMake(self.frame.size.width - self.unit, self.frame.size.height - self.unit, self.unit, self.unit);
    self.flag = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:self.flag];
    
    frame = CGRectMake(0, 0, self.unit, self.unit);
    self.name = [[UILabel alloc] initWithFrame:frame];
    self.name.font = [UIFont systemFontOfSize:16];
    self.name.shadowColor = [UIColor whiteColor];
    self.name.adjustsFontSizeToFitWidth = YES;
    self.name.textAlignment = UITextAlignmentCenter;
    self.name.backgroundColor = [UIColor clearColor];
    self.name.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    self.name.text = table.name;
    [self addSubview:self.name];
        
    CAGradientLayer *gradientLayer = [self.layer.sublayers objectAtIndex:0];
    gradientLayer.frame = tableRect; // CGRectInset(self.bounds, self.unit/2, self.unit/2);
//    gradient.cornerRadius = 4;
//    gradient.borderColor = [[UIColor grayColor] CGColor];
//    gradient.borderWidth = 1;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
//    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];		
//    [self.layer insertSublayer:gradient atIndex:0];        
    return;
}

- (ProductSymbol *)symbolBySeat: (int) seat
{
    for(UIView *view in self.subviews)
    {
        if([view isKindOfClass:[ProductSymbol class]])
            if(((ProductSymbol *)view).seat == seat)
                return (ProductSymbol *)view; 
    }        
    return nil;
}

- (void) setOrderInfo:(OrderInfo *)info
{
    CAGradientLayer *gradient = [self.layer.sublayers objectAtIndex:0];
    if(info != orderInfo) {
        orderInfo = info;
        if(orderInfo != nil)
        {
            progress.countCourses = orderInfo.countCourses;
            progress.currentCourse = orderInfo.currentCourseOffset;
            if(orderInfo.currentCourseServedOn)
                progress.currentCourseState = CourseStateServed;
            else
                progress.currentCourseState = [orderInfo.currentCourseRequestedOn timeIntervalSinceNow] < -15 * 60 ? CourseStateRequestedOverdue : CourseStateRequested;
            if(orderInfo.state == OrderStateOrdering)
                gradient.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
            else
                gradient.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:0.9 green:0.6 blue:0.6 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
            for(int seat=0; seat < table.countSeats; seat++)
            {
                ProductSymbol *symbol = [self symbolBySeat:seat];
                if(symbol != nil)
                {
                    SeatInfo *seatInfo = [orderInfo getSeatInfo:seat];
//                    if(seatInfo != nil)
//                        [symbol setFood:seatInfo.food drink: seatInfo.drink];
                }
            }
            if([[orderInfo.language lowercaseString] isEqualToString:@"nl"] == NO)
            {
                NSString *imageName = [NSString stringWithFormat:@"%@.png", [orderInfo.language lowercaseString]];
                flag.image = [UIImage imageNamed: imageName];
            }
            else
            {
                flag.image = nil;
            }
        }
        else
        {
            progress.countCourses = 0;
            progress.currentCourse = 0;
            gradient.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
            flag.image = nil;
            for(int seat=0; seat < table.countSeats; seat++)
            {
                ProductSymbol *symbol = [self symbolBySeat:seat];
                if(symbol != nil)
                {
                    [symbol setFood:nil drink: nil];
                }
            }
        }
        [self setNeedsDisplay];
        [progress setNeedsDisplay];
    }
}


- (void)drawRect : (CGRect) dirtyRect {
    CGContextRef ctf = UIGraphicsGetCurrentContext();

    int countSeatRow = table.countSeats / 2;

    CGRect tableRect = CGRectInset([self bounds], self.tableLeftMargin, self.tableTopMargin);
    
    if(table.seatOrientation == row)
    {
        float left = self.tableLeftMargin + (self.widthPerPerson - self.seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            SeatInfo *seatInfo = [self.orderInfo getSeatInfo: seat]; 
            CGRect rect = CGRectMake(left, (self.tableTopMargin - self.seatHeight)/2, self.seatWidth, self.seatHeight);
            [self drawSeat: ctf withBounds: rect info: seatInfo];
            
            seat = 2*countSeatRow - i - 1;
            if(seat < table.countSeats)
            {
	            rect = CGRectMake(left, tableRect.origin.y + tableRect.size.height + (self.tableTopMargin - self.seatHeight)/2, self.seatWidth, self.seatHeight);
                seatInfo = [self.orderInfo getSeatInfo: seat]; 
                [self drawSeat: ctf withBounds: rect info: seatInfo];
            }
            left += self.widthPerPerson;
        }
    }
    else
    {
        float top = self.tableTopMargin + (self.widthPerPerson - self.seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            SeatInfo *seatInfo = [self.orderInfo getSeatInfo: seat]; 
            CGRect rect = CGRectMake((self.tableLeftMargin - self.seatHeight)/2, top, self.seatHeight, self.seatWidth);
            [self drawSeat: ctf withBounds: rect info: seatInfo];
            
            seat = 2*countSeatRow - i - 1;
            if(seat < table.countSeats)
            {
                rect = CGRectMake(tableRect.origin.x + tableRect.size.width + (self.tableLeftMargin - self.seatHeight)/2, top, self.seatHeight, self.seatWidth);
                SeatInfo *seatInfo = [self.orderInfo getSeatInfo: seat]; 
                [self drawSeat: ctf withBounds: rect info: seatInfo];
            }
            top += self.widthPerPerson;
        }
    }
}

- (void) drawSeat: (CGContextRef)context withBounds: (CGRect) bounds info: (SeatInfo *) seatInfo
{
    UIColor * backgroundColor;
    if(seatInfo == nil)
        backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.2];
    else if(seatInfo.isMale)
        backgroundColor = [UIColor blueColor];
    else
        backgroundColor = [UIColor redColor];
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, bounds);    
}

- (void) rePosition: (Table *) newTable offset: (CGPoint) offset scaleX: (float) scaleX
{
    for(UIView *view in self.subviews) [view removeFromSuperview];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self setupByTable: newTable offset: offset scaleX:scaleX];
    }];
}

- (int) seatByPoint: (CGPoint) point
{
    int countSeatRow = table.countSeats / 2;
    
    CGRect tableRect = CGRectInset([self bounds], self.tableLeftMargin, self.tableTopMargin);

    if(table.seatOrientation == row)
    {
        float left = self.tableLeftMargin + (self.widthPerPerson - self.seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            CGRect rect = CGRectMake(left, 0, self.seatWidth, self.tableTopMargin);
            if(CGRectContainsPoint(rect, point))
               return seat;
            
            seat = 2*countSeatRow - i - 1;
            if(seat < table.countSeats)
            {
                rect = CGRectMake(left, tableRect.origin.y + tableRect.size.height, self.seatWidth, self.tableTopMargin);
                if(CGRectContainsPoint(rect, point))
                   return seat;
            }
            left += self.widthPerPerson;
        }
    }
    else
    {
        float top = self.tableTopMargin + (self.widthPerPerson - self.seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            CGRect rect = CGRectMake(0, top, self.tableLeftMargin, self.seatWidth);
            if(CGRectContainsPoint(rect, point))
               return seat;
            
            seat = 2 * countSeatRow - i - 1;
            if(seat < table.countSeats)
            {
                rect = CGRectMake(tableRect.origin.x + tableRect.size.width, top, self.tableLeftMargin, self.seatWidth);
                if(CGRectContainsPoint(rect, point))
                   return seat;
            }
            top += self.widthPerPerson;
        }
    }
    return -1;
}



@end
