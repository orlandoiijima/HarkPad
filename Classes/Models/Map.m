//
//  Map.m
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Map.h"

@implementation Map

@synthesize districts;

- (id)init {
    if ((self = [super init])) {
        districts = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (Map *) mapFromJson:(NSMutableDictionary *)d
{
    Map *map = [[Map alloc] init];
    for(NSDictionary *districtDic in [d valueForKey:@"Districts"])
    {
        District *district = [District districtFromJsonDictionary: districtDic]; 
        [map.districts addObject:district];
    }
    return map;
}

- (Table *) getTable: (NSString *) tableId
{
    for(District *district in districts)
    {
        for(Table *table in district.tables)
        {
            if([table.name isEqualToString:tableId])
                return table;
        }    
    }   
    return nil;
}

- (Table *) getTableByName: (NSString *) tableName
{
    for(District *district in districts)
    {
        for(Table *table in district.tables)
        {
            if([table.name isEqualToString:tableName])
                return table;
        }
    }
    return nil;
}

- (District *)getTableDistrict: (NSString *)tableName
{
    for(District *district in districts)
    {
        for(Table *table in district.tables)
        {
            if([table.name isEqualToString: tableName])
                return district;
        }
    }
    return nil;
}

@end
