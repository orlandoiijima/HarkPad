//
//  MenuItem.h
//  HarkPad2
//
//  Created by Willem Bison on 02-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Product.h"

@class MenuCard;

@interface MenuItem : NSObject {
}

+ (MenuItem *) menuItemFromJsonDictionary: (NSDictionary *)jsonDictionary  withCard: (MenuCard *)menuCard;

@property int course;

- (NSMutableDictionary *)toDictionary;

@property (retain) Product *product;

@end
