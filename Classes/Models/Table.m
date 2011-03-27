//
//  Table.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Table.h"
#import "Service.h"

@implementation Table
@synthesize name, bounds, district, countSeats, seatOrientation, dockedToTableId, id;


+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Table *table = [[[Table alloc] init] autorelease];
    table.name = [jsonDictionary objectForKey:@"name"];
    table.id = [[jsonDictionary objectForKey:@"id"] intValue];
    id dockedTo = [jsonDictionary objectForKey:@"dockedToTableId"];
    if((NSNull *)dockedTo != [NSNull null])
        table.dockedToTableId = [dockedTo intValue];
    else
        table.dockedToTableId = -1;
    table.countSeats = [[jsonDictionary objectForKey:@"capacity"] intValue];
    table.seatOrientation = [[jsonDictionary objectForKey:@"seatOrientation"] intValue];
    NSNumber *left = [jsonDictionary objectForKey:@"left"];
    NSNumber *top =  [jsonDictionary objectForKey:@"top"];
    NSNumber *width = [jsonDictionary objectForKey:@"width"];
    NSNumber *height = [jsonDictionary objectForKey:@"height"];
    table.bounds = CGRectMake([left floatValue], [top floatValue], [width floatValue], [height floatValue]);
    return table;
}

- (Table *) initWithBounds:(CGRect)tableBounds name: (NSString *)tableName countSeats: (int) count
{
    bounds = tableBounds;
    name = tableName;
    countSeats = count;
    return self;
}

//- (void) getNeighboursForCapacity: (int) requiredCapacity
//{
//    NSMutableArray *neighbors = [[NSMutableArray alloc] init];
//    for(Table *table in district.tables) {
//        if(table.id == self.id) continue;
//        if(table.seatOrientation == row)
//        {
//            if(table.bounds.origin.y == bounds.origin.y)
//                [neighbors addObject:table];
//        }
//        else
//        {
//            if(table.bounds.origin.x == bounds.origin.x)
//                [neighbors addObject:table];
//        }
//    }
//}


- (bool) isSeatAlignedWith: (Table *)table
{
    if(table.seatOrientation == row)
    {
        return table.bounds.origin.y == bounds.origin.y;
    }
    else
    {
        return table.bounds.origin.x == bounds.origin.x;
    }    
}

@end
