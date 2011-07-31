//
//  Product.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductCategory.h"

typedef enum Vat {Low=0, High=1} Vat;

@interface Product : NSObject {
    NSString *name;
    NSString *key;
    ProductCategory *category;
    NSString *description;
    NSDecimalNumber *price;
    int sortOrder;
    bool isQueued;
    int id;
    NSMutableArray *properties;
    Vat vat;
}


@property (retain) NSString *name;
@property (retain) NSString *key;
@property (retain) ProductCategory *category;
@property (retain) NSString *description;
@property (retain) NSDecimalNumber *price;
@property int sortOrder;
@property Vat vat;
@property bool isQueued;
@property int id;
@property (retain) NSMutableArray *properties;

+ (Product *) productFromJsonDictionary: (NSDictionary *) dict;
- (NSMutableDictionary *) initDictionary;

@end
