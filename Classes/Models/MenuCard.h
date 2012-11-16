//
//  Menu.h
//  HarkPad
//
//  Created by Willem Bison on 02-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "ProductCategory.h"
#import "Product.h"
#import "OrderLineProperty.h"

@interface MenuCard : DTO {
}

+ (MenuCard *) menuFromJson: (NSMutableDictionary *) jsonData;
- (Product *) getProduct: (NSString *) productId;

- (BOOL)isUniqueKey:(NSString *)productId itemToIgnore:(id)itemToIgnore;


- (NSString *)vatNameByPercentage:(NSDecimalNumber *)vatPercentage;
- (int)vatIndexByPercentage:(NSDecimalNumber *)vatPercentage;


- (NSDecimalNumber *)vatPercentageByIndex:(int)i;

- (OrderLineProperty *) getProductProperty: (int)propertyId;

- (BOOL)isFavorite:(id)item;

- (int)addToFavorites:(id)newItem;

- (int)removeFromFavorites:(id)item;


@property(nonatomic, strong) NSMutableArray *favorites;
@property(nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *vatPercentages;
@property(nonatomic, strong) NSDate *validFrom;
@end
