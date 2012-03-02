//
//  Guest.m
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Guest.h"
#import "Table.h"
#import "Order.h"


@implementation Guest

@synthesize id, isMale, isEmpty, isHost, seat, lines, entityState, diet, order;
@dynamic nextGuest;

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

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order
{
    Guest *guest = [[Guest alloc] init];
    guest.id = [[jsonDictionary objectForKey:@"id"] intValue];
    guest.order = order;
    guest.seat = [[jsonDictionary objectForKey:@"seat"] intValue];
    id val = [jsonDictionary objectForKey:@"diet"];
    if (val != nil)
        guest.diet = [val intValue];
    val = [jsonDictionary objectForKey:@"gender"];
    if (val != nil && [val isEqualToString:@"M"] == NO)
        guest.isMale = NO;
    id isHost = [jsonDictionary objectForKey:@"isHost"];
    if (isHost != nil)
        guest.isHost = (BOOL) [isHost intValue];
    guest.entityState = None;
    return guest;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt:self.seat] forKey:@"seat"];
    if (isMale == NO)
        [dic setObject: @"F" forKey:@"gender"];
    if (diet != 0)
        [dic setObject: [NSNumber numberWithInt:self.diet] forKey:@"diet"];
    if (isHost)
        [dic setObject: [NSNumber numberWithBool:isHost] forKey:@"isHost"];
    [dic setObject: [NSNumber numberWithInt:entityState] forKey:@"entityState"];
    return dic;
}

- (void) setDiet: (Diet) aDiet {
    diet = aDiet;
    self.entityState = Modified;
}

- (void)setIsHost:(BOOL)anIsHost {
    isHost = anIsHost;
    self.entityState = Modified;
}

- (void)setIsMale:(BOOL)anIsMale {
    isMale = anIsMale;
    self.entityState = Modified;
}

- (void) setEntityState:(EntityState)newState
{
    if(entityState == None || newState == Deleted || newState == None)
        entityState = newState;
}

- (Guest *) nextGuest {
    Guest *nextGuest = nil;
    for (Guest *guest in self.order.guests) {
        if (guest.seat > self.seat) {
            if (nextGuest == nil || guest.seat < nextGuest.seat)
                nextGuest = guest;
        }
    }
    return nextGuest;
}

@end
