//
//  District.m
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "District.h"
#import "Table.h"

@implementation District

@synthesize name, tables, id;

- (id)init {
    if ((self = [super init])) {
        tables = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (District *) districtFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    District *district = [[District alloc] init];
    district.name = [jsonDictionary objectForKey:@"name"];
    district.id = [[jsonDictionary objectForKey:@"id"] intValue];
    district.tables = [[NSMutableArray alloc] init];
    id tables = [jsonDictionary objectForKey:@"tables"];
    for(NSDictionary *item in tables)
    {
        Table *table = [Table tableFromJsonDictionary: item]; 
        table.district = district;
        [district.tables addObject:table];
    }
    return district;
}

- (CGRect) getRect
{
    if([tables count] == 0) {
        return CGRectMake(0,0,0,0);
    }
    CGRect rect = [[tables objectAtIndex:0] bounds];
    for(Table *table in tables)
    {
        if(table.bounds.origin.x < rect.origin.x)
            rect = CGRectMake(table.bounds.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        if(table.bounds.origin.y < rect.origin.y)
            rect = CGRectMake(rect.origin.x, table.bounds.origin.y, rect.size.width, rect.size.height);
        if(table.bounds.origin.x + table.bounds.size.width > rect.origin.x + rect.size.width)
            rect = CGRectMake(rect.origin.x, rect.origin.y, table.bounds.origin.x + table.bounds.size.width - rect.origin.x, rect.size.height);
        if(table.bounds.origin.y + table.bounds.size.height > rect.origin.y + rect.size.height)
            rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, table.bounds.origin.y + table.bounds.size.height - rect.origin.y);
    }
    return rect;
}


@end
