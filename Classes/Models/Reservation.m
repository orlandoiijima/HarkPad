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

+ (Reservation *) reservationFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Reservation *reservation = [[[Reservation alloc] init] autorelease];
    reservation.id = [[jsonDictionary objectForKey:@"id"] intValue];
    reservation.notes = [jsonDictionary objectForKey:@"notes"];
    reservation.name = [jsonDictionary objectForKey:@"name"];
    reservation.email = [jsonDictionary objectForKey:@"email"];
    reservation.language = [jsonDictionary objectForKey:@"language"];
    reservation.phone = [jsonDictionary objectForKey:@"phone"];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    reservation.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"startsOn"];
    reservation.startsOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"endsOn"];
    reservation.endsOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    reservation.countGuests = [[jsonDictionary objectForKey:@"countGuests"] intValue];
    NSNumber *orderId = [jsonDictionary objectForKey:@"orderId"];
    if((NSNull *)orderId != [NSNull null])
        reservation.orderId = [orderId intValue];
    else
        //  Not yet linked to order	
        reservation.orderId = -1;
    return reservation;
}

@end
