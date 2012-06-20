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
@synthesize name, bounds, district, dockedToTableId, isDocked, id, countSeatsPerSide;
@dynamic maxCountSeatsHorizontal, maxCountSeatsVertical, countSeatsTotal;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.countSeatsPerSide = [NSMutableArray arrayWithObjects: [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], nil];
        self.dockedToTableId = -1;
        self.isDocked = false;
	}
    return(self);
}


+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Table *table = [[Table alloc] init];
    table.name = [jsonDictionary objectForKey:@"name"];
    table.id = [[jsonDictionary objectForKey:@"id"] intValue];

    id dockedTo = [jsonDictionary objectForKey:@"dockedToTableId"];
    if(dockedTo != nil)
        table.dockedToTableId = [dockedTo intValue];
    
    id isDocked = [jsonDictionary objectForKey:@"isDocked"];
    if(isDocked != nil)
        table.isDocked = (BOOL)[isDocked intValue];

    id countSeats = [jsonDictionary objectForKey:@"countSeats"];
    if (countSeats != nil)
        table.countSeatsPerSide = [NSMutableArray arrayWithArray: countSeats];
    else
        table.countSeatsPerSide = [NSMutableArray arrayWithObjects: [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];

    NSNumber *left = [jsonDictionary objectForKey:@"l"];
    NSNumber *top =  [jsonDictionary objectForKey:@"t"];
    NSNumber *width = [jsonDictionary objectForKey:@"w"];
    NSNumber *height = [jsonDictionary objectForKey:@"h"];
    table.bounds = CGRectMake([left floatValue], [top floatValue], [width floatValue], [height floatValue]);
    return table;
}

- (bool) isSeatAlignedWith: (Table *)table
{
    if([[table.countSeatsPerSide objectAtIndex:0] intValue] > 0)
    {
        return table.bounds.origin.y == bounds.origin.y;
    }
    else
    {
        return table.bounds.origin.x == bounds.origin.x;
    }    
}

- (TableSide) sideForSeat: (int)seatOffset {
    if (seatOffset < [[countSeatsPerSide objectAtIndex:0] intValue])
        return TableSideTop;
    if (seatOffset < [[countSeatsPerSide objectAtIndex:0] intValue]  + [[countSeatsPerSide objectAtIndex:1] intValue])
        return TableSideRight;
    if (seatOffset < [[countSeatsPerSide objectAtIndex:0] intValue] + [[countSeatsPerSide objectAtIndex:1] intValue] + [[countSeatsPerSide objectAtIndex:2] intValue])
        return TableSideBottom;
    return TableSideLeft;
}

- (int) firstSeatAtSide: (TableSide) tableSide {
    switch (tableSide) {
        case TableSideTop:
            return 0;
        case TableSideRight:
            return [[countSeatsPerSide objectAtIndex:0] intValue];
        case TableSideBottom:
            return [[countSeatsPerSide objectAtIndex:0] intValue]  + [[countSeatsPerSide objectAtIndex:1] intValue];
        case TableSideLeft:
            return [[countSeatsPerSide objectAtIndex:0] intValue] + [[countSeatsPerSide objectAtIndex:1] intValue] + [[countSeatsPerSide objectAtIndex:2] intValue];
    }
}

- (int)countSeatsTotal {
    return [[countSeatsPerSide objectAtIndex:0] intValue] + [[countSeatsPerSide objectAtIndex:1] intValue] + [[countSeatsPerSide objectAtIndex:2] intValue] + [[countSeatsPerSide objectAtIndex:3] intValue];
}

- (int) maxCountSeatsHorizontal
{
    return MAX([[countSeatsPerSide objectAtIndex:0] intValue], [[countSeatsPerSide objectAtIndex:2] intValue]);
}
- (int) maxCountSeatsVertical
{
    return MAX([[countSeatsPerSide objectAtIndex:1] intValue], [[countSeatsPerSide objectAtIndex:3] intValue]);
}

@end
