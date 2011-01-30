//
//  Guest.m
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Guest.h"


@implementation Guest

@synthesize id, isMale, seat, lines;

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Guest *guest = [[[Guest alloc] init] autorelease];
    guest.id = [[jsonDictionary objectForKey:@"id"] intValue];
    guest.seat = [[jsonDictionary objectForKey:@"seat"] intValue];
    guest.isMale = YES; //[jsonDictionary objectForKey:@"gender"] str;
    return guest;
}

@end
