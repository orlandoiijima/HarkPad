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

@implementation Cache

static 	Cache * _cache = nil;

@synthesize menuCard, map,tree, productProperties, config;
@synthesize printInfo;


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
}

+ (void) clear
{
    _cache.menuCard = nil;
    _cache.map = nil;
    _cache.tree = nil;
    _cache.productProperties = nil;
    _cache = nil;
}

@end
