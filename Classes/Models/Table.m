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

- (bool) canUndock
{
    for(Table *table in district.tables) {
        if(table.dockedToTableId == self.id)
            return true;
    }
    return false;
}


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
