//
//  Cache.h
//  HarkPad
//
//  Created by Willem Bison on 25-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuCard.h"
#import "Map.h"
#import "Service.h"
#import "Config.h"
#import "PrintInfo.h"
#import "AppVault.h"
#import "Company.h"

@interface Cache : NSObject {
    MenuCard *menuCard;
    Map *map;
    NSMutableArray *productProperties;
    PrintInfo *printInfo;
    Config *config;
}

+ (Cache *) getInstance;
+ (void) clear;

@property (retain) MenuCard *menuCard;

- (NSMutableArray *)getLocationUsers;

@property (retain) Map *map;
@property (retain) NSMutableArray *productProperties;
@property (retain) Config *config;
@property(nonatomic, strong) PrintInfo *printInfo;

@property(nonatomic, strong) NSMutableArray *users;

@property(nonatomic, strong) NSMutableArray *locations;

@property(nonatomic) BOOL isLoaded;

@property(nonatomic, strong) Company *company;

- (void) loadFromJson:(NSMutableDictionary *)json;

@end
