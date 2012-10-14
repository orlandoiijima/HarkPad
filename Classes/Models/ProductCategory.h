//
//  ProductCategory.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTO.h"

@interface ProductCategory : DTO {
    NSString *name;
    int sortOrder;
    UIColor *color;
    BOOL isFood;
}

@property (retain) NSString *name;
@property int sortOrder;
@property (retain) UIColor *color;
@property BOOL isFood;
@property (retain) NSMutableArray *products;

+ (ProductCategory *) categoryFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (NSMutableDictionary *)toDictionary;

@end
