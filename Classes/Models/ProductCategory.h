//
//  ProductCategory.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductCategory : NSObject {
    int id;
    NSString *name;
    int sortOrder;
    UIColor *color;
    BOOL isFood;
    NSMutableArray *products;
}

@property int id;
@property (retain) NSString *name;
@property int sortOrder;
@property (retain) UIColor *color;
@property BOOL isFood;
@property (retain) NSMutableArray *products;

+ (ProductCategory *) categoryFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
