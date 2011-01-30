//
//  SeatInfo.m
//  HarkPad
//
//  Created by Willem Bison on 29-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "SeatInfo.h"
#import "Cache.h"

@implementation SeatInfo

@synthesize isMale, food, drink;

+ (SeatInfo *) seatInfoFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    SeatInfo *seatInfo = [[[SeatInfo alloc] init] autorelease];

    id foodId = [jsonDictionary objectForKey:@"foodId"];
    if((NSNull *)foodId != [NSNull null])
        seatInfo.food = [[[Cache getInstance] menuCard] getProduct:[foodId intValue]];

    id drinkId = [jsonDictionary objectForKey:@"drinkId"];
    if((NSNull *)drinkId != [NSNull null])
        seatInfo.drink = [[[Cache getInstance] menuCard] getProduct:[drinkId intValue]];
    return seatInfo;
}

@end
