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
#import "ProductSymbol.h"

@implementation TableButton

@synthesize table, orderInfo, progress, name, unit, flag, tableLeftMargin, tableTopMargin, widthPerPerson, seatWidth, seatHeight, symbolWidth;


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
    
    int countSeatRow = table.countSeats / 2;
    float seatMargin = button.unit / 2;
    float seatWidth = button.unit * 2;
    
    if(table.seatOrientation == row)
        button.unit = button.bounds.size.width / (countSeatRow * 3 + 1);
    else
        button.unit = button.bounds.size.height / (countSeatRow * 3 + 1);

    int tableDepth;
    int tableWidth;
    if(table.seatOrientation == row)
    {
        button.tableTopMargin = button.bounds.size.height / 6;
        button.tableLeftMargin = button.bounds.size.height / 12;
        tableDepth = button.bounds.size.height - 2 * button.tableTopMargin;
        tableWidth = button.bounds.size.width - 2 * button.tableLeftMargin;
    }
    else
    {
        button.tableTopMargin = button.bounds.size.width / 12;
        button.tableLeftMargin = button.bounds.size.width / 6;
        tableDepth = button.bounds.size.width - 2 * button.tableLeftMargin;   
        tableWidth = button.bounds.size.height - 2 * button.tableTopMargin;   
    }
    
    button.widthPerPerson = tableWidth / countSeatRow;
   
    button.seatWidth = (3 * button.widthPerPerson) / 4;
    button.seatHeight = button.widthPerPerson / 6;

    
    
    button.symbolWidth = tableDepth / 2 - 4;
    if(button.seatWidth < button.symbolWidth)
        button.symbolWidth = button.seatWidth; 
    
    CGRect tableRect = CGRectInset([button bounds], button.tableLeftMargin, button.tableTopMargin);
    
    //    CGContextStrokeRect(ctf, <#CGRect rect#>)
    
    int countSeatRowOpposite = table.countSeats - countSeatRow;
    
    if(table.seatOrientation == row)
    {
        float left = button.tableLeftMargin + (button.widthPerPerson - button.symbolWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            CGRect rect = CGRectMake(left, tableRect.origin.y + 2, button.symbolWidth, button.symbolWidth);
            ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
            [button addSubview: symbol];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(left, tableRect.origin.y + tableRect.size.height - button.symbolWidth - 4, button.symbolWidth, button.symbolWidth);
                ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
                [button addSubview: symbol];
            }
            
            left += button.widthPerPerson;
        }
    }
    else
    {
        float top = button.tableTopMargin + (button.widthPerPerson - button.seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            CGRect rect = CGRectMake(tableRect.origin.x + seatMargin/4, top + seatWidth/4, seatWidth / 2, seatWidth/2);
            ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
            [button addSubview: symbol];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(tableRect.origin.x + tableRect.size.width - seatMargin / 4 - seatWidth/2, top + seatWidth/4, seatWidth / 2, seatWidth/2);
                ProductSymbol *symbol = [ProductSymbol symbolWithFrame:rect seat:seat];
                [button addSubview: symbol];
            }
            top += button.widthPerPerson;
        }
        
    }
    
    CGRect frame;
     
    frame = CGRectMake(button.frame.size.width - button.widthPerPerson / 2, 0, button.widthPerPerson / 2, button.widthPerPerson / 2);
    button.progress = [CourseProgress progressWithFrame:frame countCourses:0 currentCourse:0];
    [button addSubview:button.progress];
    
    frame = CGRectMake(button.frame.size.width - button.unit, button.frame.size.height - button.unit, button.unit, button.unit);
    button.flag = [[UIImageView alloc] initWithFrame:frame];
    [button addSubview:button.flag];
    
    frame = CGRectMake(0, 0, button.unit, button.unit);
    button.name = [[UILabel alloc] initWithFrame:frame];
    button.name.font = [UIFont systemFontOfSize:16];
    button.name.shadowColor = [UIColor whiteColor];
    button.name.adjustsFontSizeToFitWidth = YES;
    button.name.textAlignment = UITextAlignmentCenter;
    button.name.backgroundColor = [UIColor clearColor];
    button.name.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    button.name.text = table.name;
    [button addSubview:button.name];
        
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = tableRect; // CGRectInset(button.bounds, button.unit/2, button.unit/2);
    gradient.cornerRadius = 4;
    gradient.borderColor = [[UIColor grayColor] CGColor];
    gradient.borderWidth = 1;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];		
    [button.layer insertSublayer:gradient atIndex:0];        
    return button;
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
        [orderInfo release];
        orderInfo = [info retain];
        if(orderInfo != nil)
        {
            progress.countCourses = orderInfo.countCourses;
            progress.currentCourse = orderInfo.currentCourse;
            progress.isCurrentCourseHot = [orderInfo.currentCourseRequestedOn timeIntervalSinceNow] < -15 * 60;
            if(orderInfo.state == ordering)
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
            else
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.9 green:0.6 blue:0.6 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
            for(int seat=0; seat < table.countSeats; seat++)
            {
                ProductSymbol *symbol = [self symbolBySeat:seat];
                if(symbol != nil)
                {
                    SeatInfo *seatInfo = [orderInfo getSeatInfo:seat];
                    if(seatInfo != nil)
                        [symbol setFood:seatInfo.food drink: seatInfo.drink];
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
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
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

//    [[UIColor yellowColor] set];
//    UIRectFill(self.bounds);
    
    int countSeatRow = table.countSeats / 2;

    CGRect tableRect = self.bounds;
    tableRect = CGRectInset([self bounds], tableLeftMargin, tableTopMargin);
    
//    CGContextStrokeRect(ctf, <#CGRect rect#>)
    
    int countSeatRowOpposite = table.countSeats - countSeatRow;
    
    if(table.seatOrientation == row)
    {
        float left = tableLeftMargin + (widthPerPerson - seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            SeatInfo *seatInfo = [self.orderInfo getSeatInfo: seat]; 
            CGRect rect = CGRectMake(left, (tableTopMargin - seatHeight)/2, seatWidth, seatHeight);
            [self drawSeat: ctf withBounds: rect info: seatInfo];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(left, tableRect.origin.y + tableRect.size.height + (tableTopMargin - seatHeight)/2, seatWidth, seatHeight);
                seatInfo = [self.orderInfo getSeatInfo: seat]; 
                [self drawSeat: ctf withBounds: rect info: seatInfo];
            }
            left += widthPerPerson;
        }
    }
    else
    {
        float top = tableTopMargin + (widthPerPerson - seatWidth) / 2;
        for(int i = 0; i < countSeatRow; i++)
        {
            int seat = i;
            SeatInfo *seatInfo = [self.orderInfo getSeatInfo: seat]; 
            CGRect rect = CGRectMake((tableLeftMargin - seatHeight)/2, top, seatHeight, seatWidth);
            [self drawSeat: ctf withBounds: rect info: seatInfo];
            
            if(i < countSeatRowOpposite)
            {
                seat += countSeatRow;
                rect = CGRectMake(tableRect.origin.x + tableRect.size.width + (tableLeftMargin - seatHeight)/2, top, seatHeight, seatWidth);
                SeatInfo *seatInfo = [self.orderInfo getSeatInfo: seat]; 
                [self drawSeat: ctf withBounds: rect info: seatInfo];
            }
            top += widthPerPerson;
        }
    }
}

- (void) drawSeat: (CGContextRef)context withBounds: (CGRect) bounds info: (SeatInfo *) seatInfo
{
    UIColor * backgroundColor;
    if(seatInfo == nil) backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.2];
    else
        if(seatInfo.isMale)
            backgroundColor = [UIColor blueColor];
    else
        backgroundColor = [UIColor redColor];
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, bounds);    
}

- (void)dealloc {
    [super dealloc];
}


@end
