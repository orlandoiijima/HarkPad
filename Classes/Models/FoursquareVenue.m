//
//  FoursquareVenue.m
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "FoursquareVenue.h"


@implementation FoursquareVenue

+ (FoursquareVenue *) venueFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    FoursquareVenue *venue = [[FoursquareVenue alloc] init];
    NSDictionary *venueDic = [jsonDictionary objectForKey:@"venue"];
    NSDictionary *statsDic = [venueDic objectForKey:@"stats"];
    venue.countCheckins = [[statsDic objectForKey:@"checkinsCount"] intValue];
    venue.countUsers = [[statsDic objectForKey:@"usersCount"] intValue];
    return venue;
}
@end
	