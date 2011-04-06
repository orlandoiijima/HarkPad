//
//  Reservation.m
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Reservation.h"

@implementation Reservation

@synthesize id, startsOn, endsOn, email, notes, phone, createdOn, countGuests, language, name, mailingList, orderId;

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
	}
    return(self);
}

+ (Reservation *) reservationFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Reservation *reservation = [[[Reservation alloc] init] autorelease];
    reservation.id = [[jsonDictionary objectForKey:@"id"] intValue];
    
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

    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    reservation.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"startsOn"];
    reservation.startsOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"endsOn"];
    reservation.endsOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    reservation.countGuests = [[jsonDictionary objectForKey:@"countPersons"] intValue];
    NSNumber *orderId = [jsonDictionary objectForKey:@"orderId"];
    if((NSNull *)orderId != [NSNull null])
        reservation.orderId = [orderId intValue];
    else
        //  Not yet linked to order	
        reservation.orderId = -1;
    return reservation;
}

- (NSDictionary *) initDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: self.name forKey:@"name"];
    [dic setObject: [NSNumber numberWithInt:self.countGuests] forKey:@"countPersons"];
    if(self.email != nil)
        [dic setObject: self.email forKey:@"email"];
    if(self.notes != nil)
        [dic setObject: self.notes forKey:@"notes"];
    [dic setObject: self.language forKey:@"language"];
    if(self.phone != nil)
        [dic setObject: self.phone forKey:@"phone"];
    [dic setObject: [NSNumber numberWithInt:[self.startsOn timeIntervalSince1970]] forKey:@"startsOn"];
    [dic setObject: [NSNumber numberWithInt:[self.createdOn timeIntervalSince1970]] forKey:@"createdOn"];
    
    return dic;
}


@end
