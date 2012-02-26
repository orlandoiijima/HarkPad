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
@synthesize name, bounds, district, countSeats, seatOrientation, dockedToTableId, isDocked, id, seatsHorizontal, seatsVertical;


- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.dockedToTableId = -1;
        self.isDocked = false;
        self.countSeats = 2;
        self.seatOrientation = row;
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

    id countSeats = [jsonDictionary objectForKey:@"capacity"];
    if(countSeats != nil)
        table.countSeats = (NSUInteger) [countSeats intValue];

    id seatOrientation = [jsonDictionary objectForKey:@"orientation"];
    if(seatOrientation != nil)
        table.seatOrientation = (SeatOrientation)[seatOrientation intValue];

    if (table.seatOrientation == 0)
        table.seatsHorizontal = table.countSeats / 2;
    else
        table.seatsVertical = table.countSeats / 2;

    NSNumber *left = [jsonDictionary objectForKey:@"l"];
    NSNumber *top =  [jsonDictionary objectForKey:@"t"];
    NSNumber *width = [jsonDictionary objectForKey:@"w"];
    NSNumber *height = [jsonDictionary objectForKey:@"h"];
    table.bounds = CGRectMake([left floatValue], [top floatValue], [width floatValue], [height floatValue]);
    return table;
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

- (TableSide) sideForSeat: (int)seatOffset {
    if (seatOffset < seatsHorizontal)
        return TableSideTop;
    if (seatOffset < seatsHorizontal + seatsVertical)
        return TableSideRight;
    if (seatOffset < seatsHorizontal + seatsVertical + seatsHorizontal)
        return TableSideBottom;
    return TableSideLeft;
}

@end
