//
//  Reservation.m
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Reservation.h"

@implementation Reservation

@synthesize id, startsOn, endsOn, email, notes, phone, createdOn, countGuests, name, mailingList;

+ (Reservation *) reservationFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Reservation *reservation = [[[Reservation alloc] init] autorelease];
    reservation.id = [[jsonDictionary objectForKey:@"id"] intValue];
    reservation.name = [jsonDictionary objectForKey:@"name"];
    reservation.email = [jsonDictionary objectForKey:@"email"];
    reservation.phone = [jsonDictionary objectForKey:@"phone"];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    reservation.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"startsOn"];
    reservation.startsOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"endsOn"];
    reservation.endsOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    reservation.countGuests = [[jsonDictionary objectForKey:@"countGuests"] intValue];
    return reservation;
}

@end
