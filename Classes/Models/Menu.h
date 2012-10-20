//
//  Menu.h
//  HarkPad2
//
//  Created by Willem Bison on 02-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTO.h"

@class MenuCard;


@interface Menu : NSObject {
    NSString *name;
    NSString *key;
    NSMutableArray *items;
    NSDecimalNumber *price;
}

@property (retain) NSString *name;
@property (retain) NSString *key;
@property (retain) NSMutableArray *items;
@property (retain) NSDecimalNumber *price;

//+ (NSMutableArray *) menuFromJson: (NSMutableArray *)jsonData;
+ (Menu *) menuFromJsonDictionary: (NSDictionary *)jsonDictionary withCard: (MenuCard *)menuCard;

+ (Menu *)nullMenu;

- (NSMutableDictionary *)toDictionary;

@end
