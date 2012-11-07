//
//  Product.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductCategory.h"
#import "EntityState.h"
#import "Guest.h"

@class OrderLineProperty;

typedef enum Vat {Low=0, High=1} Vat;

@interface Product : DTO <NSCopying> {
//    NSString *name;
//    NSString *key;
//    ProductCategory *category;
//    NSString *description;
//    NSDecimalNumber *price;
//    int sortOrder;
//    bool isQueued;
//    bool isDeleted;
//    Diet diet;
//    NSMutableArray *properties;
//    NSDecimalNumber *vat;
}


@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *key;
@property (retain) ProductCategory *category;
@property (retain, nonatomic) NSString *description;
@property (retain, nonatomic) NSDecimalNumber *price;
@property int sortOrder;
@property (retain, nonatomic) NSDecimalNumber *vatPercentage;
@property bool isQueued;
@property bool isDeleted;
@property (retain) NSMutableArray *properties;
@property (nonatomic) Diet diet;

+ (Product *)nullProduct;
+ (Product *) productFromJsonDictionary: (NSDictionary *) dict;

- (NSMutableDictionary *)toDictionary;
- (BOOL) hasProperty: (int)propertyId;
- (void) addProperty: (OrderLineProperty *) orderLineProperty;
- (void) deleteProperty: (OrderLineProperty *) orderLineProperty;

@end
