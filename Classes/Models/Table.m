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
@synthesize name, bounds, district, isDocked,  countSeatsPerSide;
@dynamic maxCountSeatsHorizontal, maxCountSeatsVertical, countSeatsTotal;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.countSeatsPerSide = [NSMutableArray arrayWithObjects: [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], nil];
        self.isDocked = false;
	}
    return(self);
}


+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Table *table = [[Table alloc] init];
    table.name = [jsonDictionary objectForKey:@"name"];

    id dockedTo = [jsonDictionary objectForKey:@"dockedTo"];
    if(dockedTo != nil && [dockedTo count] > 0)
        table.isDocked = YES;

    id countSeats = [jsonDictionary objectForKey:@"countSeats"];
    if (countSeats != nil) {
        table.countSeatsPerSide = [NSMutableArray arrayWithObjects:
                [NSNumber numberWithInt:[[countSeats objectForKey:@"top"] intValue]],
                [NSNumber numberWithInt:[[countSeats objectForKey:@"right"] intValue]],
                [NSNumber numberWithInt:[[countSeats objectForKey:@"bottom"] intValue]],
                [NSNumber numberWithInt:[[countSeats objectForKey:@"left"] intValue]], nil];
    }
    else
        table.countSeatsPerSide = [NSMutableArray arrayWithObjects: [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];

    id frame = [jsonDictionary objectForKey:@"frame"];
    if (frame != nil) {
        table.bounds = CGRectMake(
                [[frame objectForKey:@"left"] floatValue],
                [[frame objectForKey:@"top"] floatValue],
                [[frame objectForKey:@"width"] floatValue],
                [[frame objectForKey:@"height"] floatValue]);
    }
    else
        table.bounds = CGRectMake(0,0,0,0);
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
