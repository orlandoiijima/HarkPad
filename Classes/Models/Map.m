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

+ (Map *) mapFromJson:(NSMutableArray *)d
{
    Map *map = [[[Map alloc] init] autorelease];
    for(NSDictionary *districtDic in d)
    {
        District *district = [District districtFromJsonDictionary: districtDic]; 
        [map.districts addObject:district];
    }
    return map;
}

- (Table *) getTable: (int) tableId
{
    for(District *district in districts)
    {
        for(Table *table in district.tables)
        {
            if(table.id == tableId)
                return table;
        }    
    }   
    return nil;
}

- (District *) getDistrict: (int) tableId
{
    for(District *district in districts)
    {
        for(Table *table in district.tables)
        {
            if(table.id == tableId)
                return district;
        }    
    }   
    return nil;
}


@end
