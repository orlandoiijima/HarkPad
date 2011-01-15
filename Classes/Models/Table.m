//
//  Table.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Table.h"

@implementation Table
@synthesize name, bounds, district, countSeats, id;

+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Table *table = [[[Table alloc] init] autorelease];
    table.name = [jsonDictionary objectForKey:@"name"];
    table.id = [[jsonDictionary objectForKey:@"id"] intValue];
    table.countSeats = [[jsonDictionary objectForKey:@"capacity"] intValue];
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

@end
