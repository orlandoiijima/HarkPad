//
//  Guest.m
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Guest.h"


@implementation Guest

@synthesize id, isMale, seat, lines, entityState;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        lines = [[NSMutableArray alloc] init];
        isMale = YES;
        entityState = New;
	}
    return(self);
}

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Guest *guest = [[[Guest alloc] init] autorelease];
    guest.entityState = None;
    guest.id = [[jsonDictionary objectForKey:@"id"] intValue];
    guest.seat = [[jsonDictionary objectForKey:@"seat"] intValue];
    NSString *gender = [jsonDictionary objectForKey:@"gender"];
    guest.isMale = [gender isEqualToString:@"M"];
    return guest;
}

- (NSDictionary *) initDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt:self.seat] forKey:@"seat"];
    [dic setObject: isMale ? @"M" : @"F" forKey:@"gender"];
    [dic setObject: [NSNumber numberWithInt:entityState] forKey:@"entityState"];

    return dic;
}

@end
