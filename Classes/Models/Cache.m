//
//  Cache.m
//  HarkPad
//
//  Created by Willem Bison on 25-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Cache.h"
#import "Service.h"

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
            NSLog(@"Start menucard");
            _cache.menuCard = [service getMenuCard];
            NSLog(@"Start menus");
            _cache.menuCard.menus = [service getMenus];
            NSLog(@"Start map");
            _cache.map = [service getMap];
            NSLog(@"Start tree");
            _cache.tree = [service getTree];
            NSLog(@"End cacheCac");
        }
    }
    return _cache;
}

+ (void) clear
{
    _cache.menuCard = nil;
    _cache.map = nil;
    _cache.tree = nil;
    _cache = nil;
}

@end
