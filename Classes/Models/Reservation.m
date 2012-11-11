//
//  Reservation.m
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Reservation.h"
#import "NSDate-Utilities.h"
#import "AppVault.h"

@implementation Reservation

@synthesize  startsOn, endsOn, email, notes, phone, createdOn, countGuests, language, name, mailingList, orderId, table, orderState, type, paidOn		;
@synthesize locationId = _locationId;


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
        self.orderId = nil;
        self.locationId = [AppVault locationId];
	}
    return(self);
}

+ (Reservation *) reservationFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Reservation *reservation = [[Reservation alloc] initWithDictionary:jsonDictionary];

    reservation.locationId = [jsonDictionary objectForKey:@"locationId"];

    id val = [jsonDictionary objectForKey:@"notes"];
    if((NSNull *)val != [NSNull null])
       reservation.notes = val;

    reservation.name = [jsonDictionary objectForKey:@"name"];

    val = [jsonDictionary objectForKey:@"email"];
    if((NSNull *)val != [NSNull null])
        reservation.email = val;
    
    val = [jsonDictionary objectForKey:@"language"];
    if((NSNull *)val != [NSNull null])
        reservation.language = val;

    val = [jsonDictionary objectForKey:@"phone"];
    if((NSNull *)val != [NSNull null])
        reservation.phone = val;

    val = [jsonDictionary objectForKey:@"type"];
    if(val != nil && (NSNull *)val != [NSNull null])
        reservation.type = (ReservationType)[val intValue];
    
    NSString *createdOn = [jsonDictionary objectForKey:@"createdOn"];
    reservation.createdOn = [NSDate dateFromISO8601:createdOn];

    NSString *startsOn = [jsonDictionary objectForKey:@"startsOn"];
    reservation.startsOn = [NSDate dateFromISO8601:startsOn];
    
    NSString *endsOn = [jsonDictionary objectForKey:@"endsOn"];
    reservation.endsOn = [NSDate dateFromISO8601:endsOn];
    
    reservation.countGuests = [[jsonDictionary objectForKey:@"countGuests"] intValue];
    reservation.orderId = [jsonDictionary objectForKey:@"orderId"];

    NSNumber *orderState = [jsonDictionary objectForKey:@"orderState"];
    if(orderState != nil && (NSNull *)orderState != [NSNull null])
        reservation.orderState = [orderState intValue];

    NSString *paidOn = [jsonDictionary objectForKey:@"paidOn"];
    if(paidOn != nil)
        reservation.paidOn = [NSDate dateFromISO8601:paidOn];
    
    NSString *tableId = [jsonDictionary objectForKey:@"tableId"];
    if(tableId != nil && (NSNull *)tableId != [NSNull null])
        reservation.table = [[[Cache getInstance] map] getTable:tableId];

    return reservation;
}

+ (Reservation *)null
{
    Reservation *reservation = [[Reservation alloc] init];
    reservation.id = nil;
    return reservation;
}

- (BOOL) isNullReservation
{
    return id == nil;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];

    [dic setObject: _locationId forKey:@"locationId"];

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
    return orderId != nil;
}

@end
