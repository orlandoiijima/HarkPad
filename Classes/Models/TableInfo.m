//
//  TableInfo.m
//  HarkPad
//
//  Created by Willem Bison on 27-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "TableInfo.h"
#import "OrderInfo.h"

@implementation TableInfo

@synthesize table, orderInfo, isEmpty;


- (bool) isEmpty
{
    if(orderInfo == nil || orderInfo.guests == nil || [orderInfo.guests count] == 0)
        return true;
    return false;
}

- (NSComparisonResult) compare: (TableInfo *)tableInfo
{
    return [self.table.name compare:tableInfo.table.name];
}

@end
