//
//  Reservation.m
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Reservation.h"
#import "NSDate-Utilities.h"

@implementation Reservation

@synthesize id, startsOn, endsOn, email, notes, phone, createdOn, countGuests, language, name, mailingList, orderId, table, orderState, type, paidOn		;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.createdOn = [NSDate date];
        self.countGuests = 2;
        self.language = @"NL";
        self.startsOn = [NSDate date];
        self.notes = @"";
        self.name = @"";
        self.phone = @"";
        self.email = @"";
        self.type = ReservationTypePhone;
        self.orderId = -1;
	}
    return(self);
}

+ (Reservation *) reservationFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Reservation *reservation = [[Reservation alloc] init];
    reservation.id = [[jsonDictionary objectForKey:@"Id"] intValue];
    
    id val = [jsonDictionary objectForKey:@"Notes"];
    if((NSNull *)val != [NSNull null])
       reservation.notes = val;

    reservation.name = [jsonDictionary objectForKey:@"Name"];

    val = [jsonDictionary objectForKey:@"Email"];
    if((NSNull *)val != [NSNull null])
        reservation.email = val;
    
    val = [jsonDictionary objectForKey:@"Language"];
    if((NSNull *)val != [NSNull null])
        reservation.language = val;

    val = [jsonDictionary objectForKey:@"Phone"];
    if((NSNull *)val != [NSNull null])
        reservation.phone = val;

    val = [jsonDictionary objectForKey:@"Type"];
    if(val != nil && (NSNull *)val != [NSNull null])
        reservation.type = (ReservationType)[val intValue];
    
    NSString *createdOn = [jsonDictionary objectForKey:@"CreatedOn"];
    reservation.createdOn = [NSDate dateFromISO8601:createdOn];

    NSString *startsOn = [jsonDictionary objectForKey:@"StartsOn"];
    reservation.startsOn = [NSDate dateFromISO8601:startsOn];
    
    NSString *endsOn = [jsonDictionary objectForKey:@"EndsOn"];
    reservation.endsOn = [NSDate dateFromISO8601:endsOn];
    
    reservation.countGuests = [[jsonDictionary objectForKey:@"CountGuests"] intValue];
    NSNumber *orderId = [jsonDictionary objectForKey:@"OrderId"];
    if(orderId != nil && (NSNull *)orderId != [NSNull null])
        reservation.orderId = [orderId intValue];
    else
        //  Not yet linked to order	
        reservation.orderId = -1;
    NSNumber *orderState = [jsonDictionary objectForKey:@"OrderState"];
    if(orderState != nil && (NSNull *)orderState != [NSNull null])
        reservation.orderState = [orderState intValue];

    NSString *paidOn = [jsonDictionary objectForKey:@"PaidOn"];
    if(paidOn != nil)
        reservation.paidOn = [NSDate dateFromISO8601:paidOn];
    
    NSString *tableId = [jsonDictionary objectForKey:@"TableId"];
    if(tableId != nil && (NSNull *)tableId != [NSNull null])
        reservation.table = [[[Cache getInstance] map] getTable:tableId];

    return reservation;
}

+ (Reservation *)null
{
    Reservation *reservation = [[Reservation alloc] init];
    reservation.id = -1;
    return reservation;
}

- (BOOL) isNullReservation
{
    return id < 0;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    if(self.name != nil)
        [dic setObject: self.name forKey:@"name"];
    [dic setObject: [NSNumber numberWithInt:self.countGuests] forKey:@"countGuests"];
    [dic setObject: [NSNumber numberWithInt:self.type] forKey:@"type"];
    if(self.email != nil)
        [dic setObject: self.email forKey:@"email"];
    if(self.notes != nil)
        [dic setObject: self.notes forKey:@"notes"];
    [dic setObject: self.language forKey:@"language"];
    if(self.phone != nil)
        [dic setObject: self.phone forKey:@"phone"];
    [dic setObject: [self.startsOn stringISO8601] forKey:@"startsOn"];
    [dic setObject: [NSNumber numberWithInt:[self.createdOn timeIntervalSince1970]] forKey:@"createdOn"];
    
    return dic; 
}

- (bool) isPlaced
{
    return orderId != -1;
}

@end
