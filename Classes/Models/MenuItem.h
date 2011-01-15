//
//  MenuItem.h
//  HarkPad2
//
//  Created by Willem Bison on 02-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Product.h"

@interface MenuItem : NSObject {
}

+ (MenuItem *) menuItemFromJsonDictionary: (NSDictionary *)jsonDictionary;

@property int id;
@property int course;
@property (retain) Product *product;

@end
