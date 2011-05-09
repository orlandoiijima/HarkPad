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
@synthesize name, bounds, district, countSeats, seatOrientation, dockedToTableId, isDocked, id;


- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.dockedToTableId = -1;
        self.isDocked = false;
        self.countSeats = 2;
        self.seatOrientation = 0;
	}
    return(self);
}


+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Table *table = [[[Table alloc] init] autorelease];
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
        table.countSeats = [countSeats intValue];

    id seatOrientation = [jsonDictionary objectForKey:@"orientation"];
    if(seatOrientation != nil)
        table.seatOrientation = [seatOrientation intValue];
    
    NSNumber *left = [jsonDictionary objectForKey:@"l"];
    NSNumber *top =  [jsonDictionary objectForKey:@"t"];
    NSNumber *width = [jsonDictionary objectForKey:@"w"];
    NSNumber *height = [jsonDictionary objectForKey:@"h"];
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
