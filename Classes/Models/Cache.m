//
//  Cache.m
//  HarkPad
//
//  Created by Willem Bison on 25-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Cache.h"

@implementation Cache

static 	Cache * _cache = nil;

@synthesize menuCard, map,productProperties, config;
@synthesize printInfo;
@synthesize users = _users;
@synthesize locations = _locations;
@synthesize isLoaded = _isLoaded;


+ (Cache*) getInstance {
    @synchronized(self)
    {
        if(!_cache) 
        {
            _cache = [self alloc];
        }
    }
    return _cache;
}

- (void) loadFromJson:(NSMutableDictionary *)json {
    _cache.map = [Map mapFromJson:[json valueForKey:@"tableMap"]];
    _cache.menuCard = [MenuCard menuFromJson:[json valueForKey:@"menuCard"]];
    _cache.config = [Config configFromJson:[json valueForKey:@"settings"]];
    _cache.printInfo = [PrintInfo infoFromJson:[json valueForKey:@"printInfo"]];
    _cache.company = [[Company alloc] initWithDictionary:[json valueForKey: @"company"]];

    _cache.users = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *dic in [json valueForKey:@"users"]) {
        [_cache.users addObject:[User userFromJsonDictionary: dic]];
    }
    
    _isLoaded = YES;
}

+ (void) clear
{
    _cache.menuCard = nil;
    _cache.map = nil;
    _cache.productProperties = nil;
    _cache.users = nil;
    _cache.company = nil;
    _cache = nil;
}

- (NSMutableArray *)getLocationUsers {
    NSMutableArray *locationUsers = [[NSMutableArray alloc] init];
    for (User *user in _users) {
        if (user.locationId == [AppVault locationId])
            [locationUsers addObject:user];
    }
    return locationUsers;
}

@end
