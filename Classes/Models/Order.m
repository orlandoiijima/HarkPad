//
//  Order.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Order.h"

@implementation Order

@synthesize lines, tables, createdOn, state, entityState, id;


- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.lines = [[NSMutableArray alloc] init];
        self.tables = [[NSMutableArray alloc] init];
        self.createdOn = [NSDate date];
        self.state = 0;
        self.entityState = New;
	}
    return(self);
}

+ (Order *) orderFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Order *order = [[[Order alloc] init] autorelease];
    order.id = [[jsonDictionary objectForKey:@"id"] intValue];
    order.entityState = None;
    order.state = [[jsonDictionary objectForKey:@"state"] intValue];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    order.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    
    id lines =  [jsonDictionary objectForKey:@"lines"];
    for(NSDictionary *item in lines)
    {
        OrderLine *p = [OrderLine orderLineFromJsonDictionary:item];
        [order.lines addObject:p];
    }
    Cache *cache = [Cache getInstance];
    for(NSNumber *tableId in [jsonDictionary objectForKey:@"tables"])
    {
        Table *table = [cache.map getTable:[tableId intValue]]; 
        if(table != nil) {
            [order.tables addObject:table];
        }
    }
    return order;
}

+ (Order *) orderForTable: (Table *) table
{
    Order *order = [[[Order alloc] init] autorelease];
    [order.tables addObject:table];
    return order;
}

- (NSMutableDictionary *) initDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt: [self id]] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt: [self entityState]] forKey:@"entityState"];
    NSMutableArray *dicLines = [[[NSMutableArray alloc] init] autorelease];
    [dic setObject:dicLines forKey:@"lines"];
    for(OrderLine *line in [self lines])
    {
        [dicLines addObject: [line initDictionary]];
        
    }
    NSMutableArray *dicTables = [[[NSMutableArray alloc] init] autorelease];
    [dic setObject:dicTables forKey:@"tables"];
    for(Table *table in [self tables])
    {
        [dicTables addObject: [NSNumber numberWithInt: table.id]];
    }
    return dic;
}

- (NSDecimalNumber *) getAmount
{
    id total = [NSDecimalNumber zero];
    for(OrderLine *line in lines)
    {        
        total = [total decimalNumberByAdding:[line getAmount]];
    }
    return total;
}

- (int) getLastCourse
{
    int lastCourse = 0;
    for(OrderLine *line in lines)
    {        
        if(line.course > lastCourse)
            lastCourse = line.course;
    }    
    return lastCourse;
}

- (int) getLastSeat
{
    int lastSeat = 0;
    for(OrderLine *line in lines)
    {        
        if(line.seat > lastSeat)
            lastSeat = line.seat;
    }    
    return lastSeat;
}

- (NSDate *) getLastOrderDate
{
    if(lines == nil || ([lines count] == 0)) return nil;
    NSDate *latestDate = [[lines objectAtIndex:0] createdOn];
    for(OrderLine *line in lines)
    {        
        if([line.createdOn compare: latestDate] == NSOrderedDescending)
            latestDate = line.createdOn;
    }    
    return latestDate;
}

- (NSDate *) getFirstOrderDate
{
    if(lines == nil || ([lines count] == 0)) return nil;
    NSDate *firstDate = [[lines objectAtIndex:0] createdOn];
    for(OrderLine *line in lines)
    {
        if([line.createdOn compare:firstDate] == NSOrderedAscending)
            firstDate = line.createdOn;
    }    
    return firstDate;
}


- (int) getCurrentCourse
{
    if(lines == nil || ([lines count] == 0)) return -1;
    int currentCourse = -1;
    for(OrderLine *line in lines)
    {        
        if(line.requestedOn != nil)
            if(line.course > currentCourse)
                currentCourse = line.course;
    }    
    return currentCourse;
}


NSInteger compareLine(OrderLine *lineA, OrderLine * lineB, id context) 
{
    OrderGrouping orderGrouping = *((OrderGrouping *)context);
    switch(orderGrouping)
    {
        case bySeat:
            if(lineA.seat == lineB.seat)
                return lineA.course - lineB.course;
            return lineA.seat - lineB.seat;
        case byCourse:
            if(lineA.course == lineB.course)
                return lineA.seat - lineB.seat;
            return lineA.course - lineB.course;
        case byCategory:
            if(lineA.product.category.sortOrder == lineB.product.category.sortOrder) {
                if(lineA.seat == lineB.seat)
                    return lineA.course  - lineB.course;
                return lineA.seat - lineB.seat;
            }
            return lineA.product.category.sortOrder - lineB.product.category.sortOrder;
    }
    return 0;
}

- (OrderLine *) addLineWithProductId: (int)productId seat: (int) seat course: (int) course
{
    OrderLine *line = [[[OrderLine alloc] init] autorelease];
    line.entityState = New;
    line.quantity = 1;
    line.product = [[[Cache getInstance] menuCard] getProduct:productId];
    line.sortOrder = 0;
    line.seat = seat;
    line.course = course;
    [self.lines addObject:line];
    return line;
}

- (BOOL) containsProductId:(int)productId
{
    for(OrderLine *line in lines)
    {
        if(line.product.id == productId)
            return YES;
    }
    return NO;
}

@end
