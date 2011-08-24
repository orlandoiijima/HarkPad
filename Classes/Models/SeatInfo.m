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

@synthesize isMale, food, drink, guestId;

+ (SeatInfo *) seatInfoFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    SeatInfo *seatInfo = [[SeatInfo alloc] init];

    id foodId = [jsonDictionary objectForKey:@"foodId"];
    if(foodId != nil && foodId != [NSNull null])
        seatInfo.food = [[[Cache getInstance] menuCard] getProduct:[foodId intValue]];
    seatInfo.guestId = [[jsonDictionary objectForKey:@"guestId"] intValue];

    id drinkId = [jsonDictionary objectForKey:@"drinkId"];
    if(drinkId != nil  && drinkId != [NSNull null])
        seatInfo.drink = [[[Cache getInstance] menuCard] getProduct:[drinkId intValue]];

    NSString *gender = [jsonDictionary objectForKey:@"gender"];
    seatInfo.isMale = [gender isEqualToString:@"F"] == false;
    
    return seatInfo;
}

@end
