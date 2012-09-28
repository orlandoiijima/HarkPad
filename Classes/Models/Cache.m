//
//  Cache.m
//  HarkPad
//
//  Created by Willem Bison on 25-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Cache.h"
#import "Service.h"
#import "Config.h"
#import "PrintInfo.h"
#import "Location.h"
#import "AppVault.h"

@implementation Cache

static 	Cache * _cache = nil;

@synthesize menuCard, map,tree, productProperties, config;
@synthesize printInfo;
@synthesize users = _users;
@synthesize locations = _locations;


+ (Cache*) getInstance {
    @synchronized(self)
    {
        if(!_cache) 
        {
            _cache = [self alloc];
//            Service *service = [Service getInstance];
//            [service getCard];
//            _cache.menuCard.menus = [service getMenus];
//            _cache.map = [service getMap];
//            _cache.tree = [service getTree];
        }
    }
    return _cache;
}

- (void) loadFromJson:(NSMutableDictionary *)json {
    _cache.map = [Map mapFromJson:[json valueForKey:@"tableMap"]];
    _cache.menuCard = [MenuCard menuFromJson:[json valueForKey:@"menu"]];
    _cache.tree = [TreeNode nodeFromJsonDictionary:[json valueForKey:@"menuTree"] parent:nil];
    _cache.config = [Config configFromJson:[json valueForKey:@"settings"]];
    _cache.printInfo = [PrintInfo infoFromJson:[json valueForKey:@"printInfo"]];

    _cache.locations = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *dic in [json valueForKey:@"locations"]) {
        [_cache.locations addObject:[Location locationFromJsonDictionary: dic]];
    }

    _cache.users = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *dic in [json valueForKey:@"users"]) {
        [_cache.users addObject:[User userFromJsonDictionary: dic]];
    }
}

+ (void) clear
{
    _cache.menuCard = nil;
    _cache.map = nil;
    _cache.tree = nil;
    _cache.productProperties = nil;
    _cache.users = nil;
    _cache.locations = nil;
    _cache = nil;
}

- (NSMutableArray *)getLocationUsers {
    NSMutableArray *locationUsers = [[NSMutableArray alloc] init];
    for (User *user in _users) {
        if (user.locationId == -1 || user.locationId == [AppVault locationId])
            [locationUsers addObject:user];
    }
    return locationUsers;
}
@end
