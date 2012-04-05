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

@synthesize isMale, isEmpty, isHost, seat, lines, diet, order;
@dynamic nextGuest, isLast;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        lines = [[NSMutableArray alloc] init];
        isMale = YES;
        entityState = EntityStateNew;
	}
    return(self);
}

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order
{
    Guest *guest = [[Guest alloc] initWithJson:jsonDictionary];
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

    guest.entityState = EntityStateNone;

    return guest;
}

+ (NSString *) dietName: (int)offset {
    NSString *keyForName = [NSString stringWithFormat:@"Diet%d", offset];
    NSString *name =  NSLocalizedString(keyForName, nil);
    if ([name isEqualToString:keyForName])
        return @"";
    return name;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: [NSNumber numberWithInt:self.seat] forKey:@"seat"];
    if (isMale == NO)
        [dic setObject: @"F" forKey:@"gender"];
    if (diet != 0)
        [dic setObject: [NSNumber numberWithInt:self.diet] forKey:@"diet"];
    if (isHost)
        [dic setObject: [NSNumber numberWithBool:isHost] forKey:@"isHost"];
    return dic;
}

- (void) setDiet: (Diet) aDiet {
    diet = aDiet;
    self.entityState = EntityStateModified;
}

- (void)setIsHost:(BOOL)anIsHost {
    isHost = anIsHost;
    self.entityState = EntityStateModified;
}

- (void)setIsMale:(BOOL)anIsMale {
    isMale = anIsMale;
    self.entityState = EntityStateModified;
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

- (BOOL) isLast {
    int last = -1;
    for (Guest *guest in self.order.guests) {
        last = MAX(last, guest.seat);
    }
    return (self.seat == last);
}

- (NSDecimalNumber *)totalAmount
{
    id total = [NSDecimalNumber zero];
    for(OrderLine *line in lines)
    {
        NSDecimalNumber *lineTotal = [line.product.price decimalNumberByMultiplyingBy: [[NSDecimalNumber alloc] initWithInt:line.quantity]];
        total = [total decimalNumberByAdding: lineTotal];
    }
    return total;
}


- (NSString *)dietString {
    NSString *text = @"";
    for (int i = 0; i < 32; i++) {
        if (diet & (1 << i)) {
            NSString *dietName = [Guest dietName:i];
            if ([dietName length] == 0) break;
            if ([text length] > 0)
                text = [text stringByAppendingString:@", "];
            text = [text stringByAppendingString:dietName];
        }
    }
    return [text lowercaseString];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Seat", nil), seat+1];
}

@end
