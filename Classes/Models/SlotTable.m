//
//  SlotTable.m
//  HarkPad
//
//  Created by Willem Bison on 23-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "SlotTable.h"
#import "OrderLine.h"
#import "Table.h"
#import "Cache.h"

@implementation SlotTable

@synthesize lines, table;


+ (SlotTable *) slotTableFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    SlotTable *slotTable = [[SlotTable alloc] init];

    slotTable.lines = [[NSMutableArray alloc] init];
    id lines =  [jsonDictionary objectForKey:@"lines"];
    for(NSDictionary *item in lines)
    {
        OrderLine *line = [OrderLine orderLineFromJsonDictionary:item guests: nil courses: nil];
        [slotTable.lines addObject:line];
    }
    
    Cache *cache = [Cache getInstance];
    int tableId = [[jsonDictionary objectForKey:@"tableId"] intValue];
    slotTable.table = [cache.map getTable:tableId]; 
    
    return slotTable;
}

@end
