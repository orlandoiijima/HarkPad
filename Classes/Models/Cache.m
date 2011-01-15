//
//  Cache.m
//  HarkPad
//
//  Created by Willem Bison on 25-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Cache.h"
#import "Service.h"
#import "TestService.h"

@implementation Cache

static 	Cache * _cache = nil;

@synthesize menuCard, map,tree;

+ (Cache*) getInstance {
    @synchronized(self)
    {
        if(!_cache) 
        {
            _cache = [self alloc];
            id service = [Service getInstance];
            _cache.menuCard = [service getMenuCard];
            _cache.menuCard.menus = [service getMenus];
            _cache.map = [service getMap];
            _cache.tree = [service getTree];
        }
    }
    return _cache;
}

@end
